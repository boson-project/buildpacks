///usr/bin/true; exec /usr/bin/env go run "$0" "$@"

package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)


const repo = "ghcr.io/boson-project"

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sigs
		cancel()
		<-sigs
		os.Exit(1)
	}()

	version := os.Args[1]
	err := runTests(ctx, version)
	if err != nil {
		fmt.Printf("::error::%s\n", err.Error())
		os.Exit(1)
	}
}

var builders = []struct {
	BuilderImage string
	Runtimes     []string
}{
	{
		BuilderImage: "quay.io/boson/faas-go-builder",
		Runtimes:     []string{"go"},
	},
	{
		BuilderImage: "quay.io/boson/faas-python-builder",
		Runtimes:     []string{"python"},
	},
	{
		BuilderImage: "quay.io/boson/faas-nodejs-builder",
		Runtimes:     []string{"node", "typescript"},
	},
	{
		BuilderImage: "quay.io/boson/faas-jvm-builder",
		Runtimes:     []string{"quarkus", "springboot"},
	},
	{
		BuilderImage: "quay.io/boson/faas-quarkus-native-builder",
		Runtimes:     []string{"quarkus"},
	},
	{
		BuilderImage: "quay.io/boson/faas-rust-builder",
		Runtimes:     []string{"rust"},
	},
}

func runTests(ctx context.Context, version string) error {

	os.Setenv("FUNC_REGISTRY", repo)

	for i := range builders {
		builders[i].BuilderImage = fmt.Sprintf("%s:%s", builders[i].BuilderImage, version)
	}

	lifecycleVersion := make(map[string]bool)
	builderToLifecycle := make(map[string]string)

	for _, builder := range builders {
		v, err := getLifecycleVersion(ctx, builder.BuilderImage)
		if err != nil {
			return err
		}
		lifecycleImage := "quay.io/boson/lifecycle:" + v
		builderToLifecycle[builder.BuilderImage] = lifecycleImage
		if _, ok := lifecycleVersion[v]; !ok {
			cmd := exec.CommandContext(ctx, "docker", "pull", lifecycleImage)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stdout
			err := cmd.Run()
			if err != nil {
				return err
			}
			lifecycleVersion[v] = true
		}
	}

	wd, err := os.Getwd()
	if err != nil {
		return err
	}
	
	packCmd := "pack"
	if pc, ok := os.LookupEnv("PACK_CMD"); ok {
		packCmd = pc
	}

	funcBinaries := []string{
		filepath.Join(wd, "bin", "func_snapshot"),
		// commented for now because the test would take too long
		//filepath.Join(wd, "bin", "func_stable"),
	}
	templates := []string{
		"http",
		"events",
	}

	oldWD, err := os.Getwd()
	if err != nil {
		return err
	}

	testDir, err := os.MkdirTemp("", "test_func")
	if err != nil {
		return err
	}
	defer os.RemoveAll(testDir)

	err = os.Chdir(testDir)
	if err != nil {
		return err
	}
	defer os.Chdir(oldWD)

	// just a counter to avoid name collision
	var fnNo int

	for _, funcBinary := range funcBinaries {
		for _, builder := range builders {
			builderImage := builder.BuilderImage
			lifecycleImage := builderToLifecycle[builderImage]
			for _, runtime := range builder.Runtimes {
				for _, template := range templates {
					fnName := fmt.Sprintf("fn-%s-%s-%d", runtime, template, fnNo)
					if !runTest(ctx, packCmd, funcBinary, builderImage, lifecycleImage, runtime, template, fnName) {
						return fmt.Errorf("some test failed")
					}

					fnNo++
				}
			}
		}
	}
	return nil
}

func runTest(ctx context.Context, packCmd, funcBinary, builderImage, lifecycleImage, runtime, template, fnName string) (succeeded bool) {
	start := time.Now()

	fmt.Printf("[RUNNING TEST]\nbuilder: %s\nruntime: %s\ntemplate: %s\nfunc: %s\n",
		builderImage, runtime, template, funcBinary)

	var errs []error

	defer func() {
		fmt.Printf("duration: %s\n", time.Since(start))
		if len(errs) > 0 {
			fmt.Println("❌ Failure")
			for _, e := range errs {
				fmt.Printf("::error::%s\n", e.Error())
			}
			succeeded = false
		} else {
			fmt.Println("✅ Success")
			succeeded = true
		}
	}()


	fmt.Println("::group::Output")
	defer fmt.Println("::endgroup::")

	runCmd := func(name string, arg ...string) error {

		cmdCtx, cmdCancel := context.WithCancel(context.Background())
		cmd := exec.CommandContext(cmdCtx, name, arg...)
		cmd.Stdout = os.Stdout
		errOut := bytes.NewBuffer(nil)
		cmd.Stderr = io.MultiWriter(os.Stdout, errOut)
		cmd.Start()
		go func() {
			<-ctx.Done()
			cmd.Process.Signal(os.Interrupt)
			time.Sleep(time.Second * 10)
			cmdCancel()
		}()
		err := cmd.Wait()
		if err != nil {
			return fmt.Errorf("%w (stderr: %q)", err, errOut.String())
		}
		return nil
	}

	err := runCmd(
		funcBinary,
		"create", fnName,
		"--runtime", runtime,
		"--template", template,
		"--verbose")
	if err != nil {
		e := fmt.Errorf("failed to create a function: %w", err)
		fmt.Println(e)
		errs = append(errs, e)
		return
	}

	err = runCmd(
		packCmd,
		"--trust-builder=false",
		"build", repo+"/"+fnName+":latest",
		"--builder", builderImage,
		"--lifecycle-image", lifecycleImage,
		"--pull-policy=never",
		"--verbose",
		"--path", fnName)
	if err != nil {
		e := fmt.Errorf("failed to build the function using `pack` (--trust-builder=false): %w", err)
		fmt.Println(e)
		errs = append(errs, e)
	}

	err = runCmd(
		packCmd,
		"--trust-builder=true",
		"build", repo+"/"+fnName+":latest",
		"--builder", builderImage,
		"--lifecycle-image", lifecycleImage,
		"--pull-policy=never",
		"--verbose",
		"--path", fnName)
	if err != nil {
		e := fmt.Errorf("failed to build the function using `pack` (--trust-builder=true): %w", err)
		fmt.Println(e)
		errs = append(errs, e)
	}

	return
}

func getLifecycleVersion(ctx context.Context, builderImage string) (string, error) {
	var inspectData []struct {
		Config struct {
			Labels map[string]string
		}
	}
	pr, pw := io.Pipe()
	decoder := json.NewDecoder(pr)

	errOut := bytes.NewBuffer(nil)
	cmd := exec.CommandContext(ctx, "docker", "image", "inspect", builderImage)
	cmd.Stdout = pw
	cmd.Stderr = errOut

	err := cmd.Start()
	if err != nil {
		return "", err
	}

	err = decoder.Decode(&inspectData)
	if err != nil {
		return "", err
	}

	err = cmd.Wait()
	if err != nil {
		return "", fmt.Errorf("failed to get builder's lifecycle version: %w (stderr: %q)", err, errOut.String())
	}

	var metadataStr string
	if len(inspectData) > 0 {
		if md, ok := inspectData[0].Config.Labels["io.buildpacks.builder.metadata"]; ok {
			metadataStr = md
		}
	}
	if metadataStr == "" {
		return "", fmt.Errorf("failed to get image metadata")
	}

	metadata := struct {
		Lifecycle struct{
			Version string
		}
	}{}

	decoder = json.NewDecoder(strings.NewReader(metadataStr))
	err = decoder.Decode(&metadata)
	if err != nil {
		return "", nil
	}

	return metadata.Lifecycle.Version, nil
}
