# Deploying the example to kubernetes

NOTE: The following process is a bit manual and needs scripting!

* You will need an AKS cluster with DAPR and KEDA installed.  
* An Azure Container Registry
* A Storage Account
* A Service Bus Namespace 

The AKS cluster will need to be attached to your Container Registry (az aks update --attach-acr <ACR_RESOURCE_ID>...)

You will need to be connect your kubectl to the AKS cluster (az aks get-credentials...)

The easiest way to install Dapr is using the preview extension [https://docs.microsoft.com/en-us/azure/aks/dapr]()

Setting up Keda is a bit more involved [https://keda.sh/docs/1.4/deploy/]()

Next you are going to need to create some secrets used by the components.

First up for KEDA, create a new yaml file (keda-secrets.yaml) containing something similar to the following...

```
apiVersion: v1
kind: Secret
metadata:
  name: keda-secrets
type: Opaque
data:
  azure-storage-connectionstring :  <BASE64 ENCODED CONNECTION STRING>
```

and deploy this to the cluster `kubectl apply -f keda-secrets.yaml`

Similarly for Dapr, create a yaml file (dapr-secrets.yaml) containing

```
apiVersion: v1
kind: Secret
metadata:
  name: dapr-secrets
type: Opaque
data:
  secret-type: <BASE64 ENCODED SAMPLE TEXT>
  storage-account-name: <BASE64 ENCODED STORAGE ACCOUNT NAME>
  storage-account-key: <BASE64 ENCODED STORAGE ACCOUNT KEY>
  service-bus-connection-string: <BASE64 ENCODED CONNECTION STRING>

```
and deploy this to the cluster `kubectl apply -f dapr-secrets.yaml`

Now you need to add all the Dapr components...

```
kubectl apply -f ./components/kubernetes-secretStore.yaml
kubectl apply -f ../components/storage-state.yaml
kubectl apply -f ../components/inputbinding1-storagequeue.yaml
kubectl apply -f ../components/outputbinding1-storagequeue.yaml
kubectl apply -f ../components/inputbinding2-servicebus.yaml
kubectl apply -f ../components/outputbinding2-servicebus.yaml
```

Now build the app and push to the container registry

```
az acr build -r <ACRNAME> -f ../DockerFile -t "daprmvc:<VERSION>" ../

```
You will need to update [./daprmvc-deployment.yaml]() to point at your image in your ACR
then deploy it..

```
kubectl apply -f daprmvc-deployment.yaml
```

You will need to update [./keda.yaml]() to point at your storage account (the key will be loaded from secrets)
then deploy it..

```
kubectl apply -f keda.yaml
```

The number of pods will scale to zero when idle but instances will be added as more messages are pushed to the storage queue.



