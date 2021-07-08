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
		fmt.Fprintf(os.Stdout, "::error::%s", err.Error())
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

	for _, builder := range builders {
		v, err := getLifecycleVersion(builder.BuilderImage)
		if err != nil {
			return err
		}
		if _, ok := lifecycleVersion[v]; !ok {
			cmd := exec.CommandContext(ctx, "docker", "pull", "buildpacksio/lifecycle:" + v)
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

	packCmd := filepath.Join(wd, "pack")

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
			for _, runtime := range builder.Runtimes {
				for _, template := range templates {
					fnName := fmt.Sprintf("fn-%s-%s-%d", runtime, template, fnNo)
					report := runTest(ctx, packCmd, funcBinary, builderImage, runtime, template, fnName)
					printTestReport(report)
					if len(report.Errors) > 0 {
						return fmt.Errorf("somet test failed")
					}
					fnNo++
				}
			}
		}
	}
	return nil
}

type testReport struct {
	BuilderImage string
	Runtime      string
	Template     string
	FuncBinary   string
	Errors       []error
	Output       []byte
	Duration     time.Duration
}

func runTest(ctx context.Context, packCmd, funcBinary, builderImage, runtime, template, fnName string) (report testReport) {

	output := bytes.NewBuffer(nil)
	report = testReport{
		BuilderImage: builderImage,
		Runtime:      runtime,
		Template:     template,
		FuncBinary:   funcBinary,
	}

	start := time.Now()

	defer func() {
		report.Output = output.Bytes()
		report.Duration = time.Since(start)
	}()

	runCmd := func(name string, arg ...string) error {
		cmd := exec.CommandContext(ctx, name, arg...)
		cmd.Stdout = output
		cmd.Stderr = output
		return cmd.Run()
	}

	err := runCmd(
		funcBinary,
		"create", fnName,
		"--runtime", runtime,
		"--template", template,
		"--verbose")
	if err != nil {
		e := fmt.Errorf("failed to create a function: %w", err)
		fmt.Fprintln(output, e)
		report.Errors = append(report.Errors, e)
		return
	}

	err = runCmd(
		packCmd,
		"--trust-builder=false",
		"build", repo+"/"+fnName+":latest",
		"--builder", builderImage,
		"--pull-policy=never",
		"--verbose",
		"--path", fnName)
	if err != nil {
		e := fmt.Errorf("failed to build the function using `pack` (--trust-builder=false): %w", err)
		fmt.Fprintln(output, e)
		report.Errors = append(report.Errors, e)
	}

	err = runCmd(
		packCmd,
		"--trust-builder=true",
		"build", repo+"/"+fnName+":latest",
		"--builder", builderImage,
		"--pull-policy=never",
		"--verbose",
		"--path", fnName)
	if err != nil {
		e := fmt.Errorf("failed to build the function using `pack` (--trust-builder=true): %w", err)
		fmt.Fprintln(output, e)
		report.Errors = append(report.Errors, e)
	}

	return
}

func printTestReport(report testReport) {
	fmt.Fprintf(os.Stdout, "[TEST REPORT]\nbuilder: %s\nruntime: %s\ntemplate: %s\nfunc: %s\nduration: %s\n",
		report.BuilderImage, report.Runtime, report.Template, report.FuncBinary, report.Duration)
	if len(report.Errors) > 0 {
		fmt.Fprintln(os.Stdout, "❌ Failure")
		for _, e := range report.Errors {
			fmt.Fprintf(os.Stdout, "::error::%s\n", e.Error())
		}
	} else {
		fmt.Fprintln(os.Stdout, "✅ Success")
	}
	fmt.Fprintln(os.Stdout, "::group::Output")
	fmt.Fprintln(os.Stdout, string(report.Output))
	fmt.Fprintln(os.Stdout, "::endgroup::")
}

func getLifecycleVersion(builderImage string) (string, error) {
	var inspectData []struct {
		Config struct {
			Labels map[string]string
		}
	}
	pr, pw := io.Pipe()
	decoder := json.NewDecoder(pr)

	cmd := exec.Command("docker", "image", "inspect", builderImage)
	cmd.Stdout = pw
	cmd.Stderr = pw

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
		return "", err
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
