# Node.js Cloud Events Function

Welcome to your new Node.js function project! The boilerplate function code can be found in [`index.js`](./index.js). This function is meant to respond exclusively to [Cloud Events](https://cloudevents.io/), but you can remove the check for this in the function and it will respond just fine to plain vanilla incoming HTTP requests. Additionally, this example function is written asynchronously, returning a `Promise`. If your function does not perform any asynchronous execution, you can safely remove the `async` keyword from the function, and return raw values intead of a `Promise`.

## Local execution

After executing `npm install`, you can run this function locally by executing `npm run local`.

The runtime will expose three endpoints.

  * `/` The endpoint for your function.
  * `/health/readiness` The endpoint for a readiness health check
  * `/health/liveness` The endpoint for a liveness health check

The health checks can be accessed in your browser at [http://localhost:8080/health/readiness]() and [http://localhost:8080/health/liveness](). You can use `curl` to `POST` an event to the function endpoint:

```console
curl -X POST -d '{"hello": "world"}' \
  -H'Content-type: application/json' \
  -H'Ce-id: 1' \
  -H'Ce-source: cloud-event-example' \
  -H'Ce-type: dev.knative.example' \
  -H'Ce-specversion: 1.0' \
  http://localhost:8080
```

The readiness and liveness endpoints use [overload-protection](https://www.npmjs.com/package/overload-protection) and will respond with `HTTP 503 Service Unavailable` with a `Client-Retry` header if your function is determined to be overloaded, based on the memory usage and event loop delay.

## Container execution

It is easy to run this function in a container, simulating its execution environment on a Kubernetes cluster. When running this way, the container's port `8080` is mapped to your local port `8080`, so you can access the endpoints exactly the same as you do when running on `localhost`.

```console
appsody run
```

When running in the container, your function will be reloaded when it changes so that you can edit your source code and see the changes reflected in your browser immediately. Try it! Start your application using `appsody run`, then change [index.js](./index.js) so that it returns `'Hello world!'` if there is no incoming Cloud Event.

## Testing

This function project includes a [unit test](./test/unit.js) and an [integration test](./test/integration.js). Tests can either be run locally, or within a container execution environment. In either execution environment, all `.js` files in the test directory are run.

### Local testing

```console
npm test
```

### Container testing

```console
appsody test
```

## Deployment

```shell
PROJECT=my-name-space # replace with your namespace
DOCKER_REGISTRY=quay.io/my-user # replace with your registry
FUNCTION_NAME=my-function # replace with your function name

# build, create image and push it to the registry
appsody build --tag "${DOCKER_REGISTRY}/${FUNCTION_NAME}:v1" --push --knative

# deploy the app as knative service (and installs appsody operator if needed)
appsody deploy --knative --no-build -n ${PROJECT}
```
When doing first deploy (that includes appsody oprator installation into the namespace) there might be a timing issue [Appsody F.A.Q.](https://appsody.dev/docs/faq/#3-why-is-appsody-deploy-not-displaying-the-url-of-the-knative-service)
