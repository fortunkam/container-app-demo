# DAPR and KEDA Experiments

This project is the culmination of a set of experiments with DAPR, KEDA and Azure Container Apps.

It comprises of a dotnet 6 minimal API application that has the following features.

* Uses DAPR to be triggered when a message arrives on a Storage Queue (Input Binding)
* Uses DAPR to be triggered when a message arrives on a Service Bus Queue (Input Binding)
* Uses DAPR to write to a Storage Queue (Output Binding)
* Uses DAPR to write to a Service Bus Queue (Output Binding)
* Uses DAPR to store some state to blob storage (State Store)
* Uses DAPR to retrieve secrets (Secret Store)
* Uses KEDA to scale the image based on the number of messages in the Storage Queue (for AKS)
* Uses KEDA to scale the image based on the number of messages in the Service Bus Queue (for Container Apps)

(This example was put together in collaboration with Chris Reddington and you can find a similar example at his repo [https://github.com/chrisreddington/DaprExample]() )

