## Boson Project Buildpacks

This repository contains the necessary code to create CNCF buildpacks for functions.

### Usage

Run `make all` to ensure that you have all of the necessary images created
and available in your local Docker daemon.

### Building a Sample Node.js Application

Set your default builder to the one that you just created.

```console
pack set-default-builder boson/faas-nodejs-builder
```

Then you can build a Node.js function app.

```console
pack build hello-nodejs -p apps/hello-nodejs
```

Run the app using Docker

```console
docker run --rm -p 8080:8080 hello-nodejs
```

Send the app a Cloud Event

```console
curl -X POST -d '{"hello": "world"}' \
    -H'Content-type: application/json' \
    -H'Ce-id: 1' \
    -H'Ce-source: cloud-event-example' \
    -H'Ce-type: dev.knative.example' \
    -H'Ce-specversion: 1.0' \
    http://localhost:8080
```
