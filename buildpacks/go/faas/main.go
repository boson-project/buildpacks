package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strconv"

	cloudevents "github.com/cloudevents/sdk-go/v2"

	function "function"
)

var (
	usage   = "run\n\nRuns a CloudFunction CloudEvent handler."
	verbose = flag.Bool("V", false, "Verbose logging [$VERBOSE]")
	port    = flag.Int("port", 8080, "Listen on all interfaces at the given port [$PORT]")
)

func main() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, usage)
		flag.PrintDefaults()
	}
	parseEnv()   // override static defaults with environment.
	flag.Parse() // override env vars with flags.
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

// run a cloudevents client in receive mode which invokes
// the user-defined function.Handler on receipt of an event.
func run() (err error) {
	transport, err := cloudevents.NewHTTP(
		cloudevents.WithPort(*port),
		cloudevents.WithPath("/"))
	if err != nil {
		return
	}
	client, err := cloudevents.NewClient(transport)
	if err != nil {
		return
	}
	if *verbose {
		fmt.Printf("listening on http port %v for JSON-encoded CloudEvents\n", *port)
	}
	err = client.StartReceiver(context.Background(), function.Handle)
	// TODO: wait for signal, cancel receiver context, and wait for graceful shutdown.
	return
}

// parseEnv parses environment variables, populating the destination flags
// prior to the builtin flag parsing.  Invalid values exit 1.
func parseEnv() {
	parseBool := func(key string, dest *bool) {
		if val, ok := os.LookupEnv(key); ok {
			b, err := strconv.ParseBool(val)
			if err != nil {
				fmt.Fprintf(os.Stderr, "%v is not a valid boolean\n", key)
				os.Exit(1)
			}
			*dest = b
		}
	}
	parseInt := func(key string, dest *int) {
		if val, ok := os.LookupEnv(key); ok {
			n, err := strconv.Atoi(val)
			if err != nil {
				fmt.Fprintf(os.Stderr, "%v is not a valid integer\n", key)
				os.Exit(1)
			}
			*dest = n
		}
	}

	parseBool("VERBOSE", verbose)
	parseInt("PORT", port)
}
