#!/bin/bash

# Create a resource group

RESOURCE_GROUP='container-apps-rg'
LOCATION='westeurope'
IMAGE_TAG='daprtest:v1.0'

az group create -n $RESOURCE_GROUP --location $LOCATION

# Deploy the Base resources

az deployment group create -g $RESOURCE_GROUP --template-file ./baseResource.bicep

ACR_NAME=$(az acr list -g $RESOURCE_GROUP --query [0].name -o tsv)

# Build the ACR image

az acr build --registry $ACR_NAME -g $RESOURCE_GROUP --file ../DockerFile --image $IMAGE_TAG ../

# Deploy the container env

az deployment group create -g $RESOURCE_GROUP --template-file ./containerapp.bicep --parameters containerAppImage=$IMAGE_TAG
