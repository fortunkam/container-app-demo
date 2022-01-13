# DAPR and KEDA Experiments

This project is the culmination of a set of experiments with [DAPR](https://dapr.io/), [KEDA](https://keda.sh/) and [Azure Container Apps](https://docs.microsoft.com/en-us/azure/container-apps/).

It comprises of a dotnet 6 minimal API application that has the following features.

* Uses DAPR to be triggered when a message arrives on a Storage Queue (Input Binding)
* Uses DAPR to be triggered when a message arrives on a Service Bus Queue (Input Binding)
* Uses DAPR to write to a Storage Queue (Output Binding)
* Uses DAPR to write to a Service Bus Queue (Output Binding)
* Uses DAPR to store some state to blob storage (State Store)
* Uses DAPR to retrieve secrets (Secret Store)
* Uses KEDA to scale the image based on the number of messages in the Storage Queue (for AKS)
* Uses KEDA to scale the image based on the number of messages in the Service Bus Queue (for Container Apps)

Also included are a set of scripts for deploying the solution to an [Azure Container App](https://docs.microsoft.com/en-us/azure/container-apps/).  Note: Azure container apps is currently in preview.

## Running Locally

To run the solution locally you will need to create a local secrets file in the components folder called "local-secrets.json".  It should contain the following...

```
{
    "dapr-secrets" : {
        "secret-type" : "Local",
        "storage-account-name": "<A STORAGE ACCOUNT NAME>",
        "storage-account-key": "<A STORAGE ACCOUNT KEY",
        "service-bus-connection-string": "<A SERVICE BUS CONNECTION STRING>"
    }
}
```

You can run then run the project locally (assuming you have DAPR installed) with the following command from the root of the project.

```
dapr run --log-level debug --app-id bindingtest --app-port 7037 --dapr-http-port 3602 --dapr-grpc-port 60002 --app-ssl --components-path './components'  dotnet run
```

(You might need to tweak the app port to match the port your dotnet app runs on for https)

## Running in AKS

See the [./kubernetes/deploy.md](./kubernetes/deploy.md) for details on deploying the sample on AKS.


## Running in Azure Container Apps

See the [./containerapp/deploy.md](./containerapp/deploy.md) for details on deploying the sample to Azure Container Apps.

(This example was put together in collaboration with Chris Reddington and you can find a similar example at his repo [https://github.com/chrisreddington/DaprExample](https://github.com/chrisreddington/DaprExample) )

