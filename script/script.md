# Demoing Container Apps

## HTTP

Deploy baseResource.bicep
Deploy containerappenvironment.bicep

Show resources deployed

Open SimpleAPI project folder
Open Program.cs

Add following path

```
app.MapGet("/", ()=> {
    return "Container Apps can do HTTP!";
});
```

test with .net run
Browse to http address

Set up some variable names
```
ACR_NAME='cappmfacr'
RESOURCE_GROUP='container-app-demo'
IMAGE_TAG='simpleapi:v1'
```


Build and push to container registry (substitute values accordingly)

```
az acr build --registry $ACR_NAME -g $RESOURCE_GROUP --file DockerFile --image $IMAGE_TAG .
```

Show version deployed to container registry

Run simpleapi.bicep

```
az deployment group create -g $RESOURCE_GROUP --template-file ./simpleapi.bicep
```

Make change to API and repush to acr

```
IMAGE_TAG='simpleapi:v2'
az acr build --registry $ACR_NAME -g $RESOURCE_GROUP --file DockerFile --image $IMAGE_TAG .
```

Run simpleapiv2.bicep

```
az deployment group create -g $RESOURCE_GROUP --template-file ./simpleapiv2.bicep
```

Show you are still able to call each version independently using the label
Show the should give you 50/50 split on revisions.

## DAPR

```
app.MapPost("/readqueue", async ([FromBody]int orderId)=> {
    Console.WriteLine("Input Binding 1: Received Message: " + orderId);

    string BINDING_NAME = "writequeue";

    using var client = new DaprClientBuilder().Build();
    await client.InvokeBindingAsync(BINDING_NAME, BINDING_OPERATION, $"Input Binding 1 to Output Binding 1: {orderId}");

    Thread.Sleep(2000);
    return "CID" + orderId;
});
```

rebuild and deploy the image

```
IMAGE_TAG='daprqueue:v1'
az acr build --registry $ACR_NAME -g $RESOURCE_GROUP --file DockerFile --image $IMAGE_TAG .
```

talk about and deploy the dapr components

```
az deployment group create -g $RESOURCE_GROUP --template-file ./daprcomponents.bicep
```

Show these in the environment

Show and deploy readwritequeue.bicep container app 

```
az deployment group create -g $RESOURCE_GROUP --template-file ./readwritequeue.bicep
```

put message on queue and show being written to output (make sure not to encode in base 64)

## KEDA

Show and deploy readwritequeuekeda.bicep container app 

```
az deployment group create -g $RESOURCE_GROUP --template-file ./readwritequeuekea.bicep
```

Can test with sendMessages.sh, just make sure user has Storage Account Contributor/Storage Queue Contributor role on storage account 

```
for i in {1..100}; do az storage message put --auth-mode login --queue-name "ca-sa-queue-input" --account-name "cappmfimqpyajp2usy2" --content $i; done
```


Metrics show scaling behaviour

