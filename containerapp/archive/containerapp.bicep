/*
  This Bicep file takes several string paramter inputs, including - 
  containerAppImage - Full docker image name, e.g. cwcaks.azurecr.io/daprexample/consumer:cb9
  containerRegistry - Full ACR URL, e.g. cwcaks.azurecr.io
  containerRegistryUsername - ACR Username, e.g. cwcaks
  serviceBusQueueName - Name of the queue that we want to consume from, e.g. testqueue
  containerRegistryPassword - A secure string, 
*/
param prefix string = 'cappmf'

param containerAppImage string = 'daprtest:v1.0'
// Also take an object as an input for the tags parameter. This is used to cascade resource tags to all resources.
param tags object = {}

// Set location as a parameter with a default of the Resource Group Location. This allows for overrides if needed, and is a templating best practice.
param location string = resourceGroup().location

/*
  This Bicep file uses several varaibles to aid in readability - 
  environmentName - The name of the Container App Environment
  minReplicas - Minimum number of container instances to run
  maxReplicas - Maximum number of container instances to run
  containerAppServiceAppName - The name of the Container App App
  workspaceName - Name of the Log Analytics Workspace to be created
  appInsightsName - Name of the App Insights resource to be created
  containerRegistryPasswordRef - An identifier/reference for the container registry password. This is the same concept as refs directly within DAPR/KEDA.
  serviceBusConnectionStringRef - An identifier/reference for the Service Bus Connection String. This is the same concept as refs directly within DAPR/KEDA.
*/

var minReplicas = 1
var maxReplicas = 2
var acrName = '${prefix}acr'
var acrLoginServerName = '${prefix}acr.azurecr.io'
var containerAppServiceAppName = 'mf-container-app'
var workspaceName = '${prefix}-log-analytics'
var appInsightsName = '${prefix}-app-insights'
var containerRegistryPasswordRef = 'container-registry-password'
var storageAccountNameRef = 'storage-account-name'
var storageAccountKeyRef = 'storage-account-key'
var serviceBusConnectionStringRef = 'service-bus-connection-string'

var serviceBusName = '${prefix}-service-bus'
var serviceBusAuthRule = '${prefix}-service-bus-auth-rule'
var storageAccountName = '${prefix}${uniqueString(resourceGroup().id)}'

param serviceBusInputQueueName string = 'ca-sb-queue-input'
param serviceBusOutputQueueName string = 'ca-sb-queue-output'
param storageQueueInputName string = 'ca-sa-queue-input'
param storageQueueOutputName string = 'ca-sa-queue-output'

// Definition for the existing Log Analytics Workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: workspaceName
}

// Definition for the existing App Insights Resource
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

// Definition for the existing Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: acrName
}

// Definition for the existing storage account
resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource servicebusnamespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' existing = {
  name: serviceBusName
}

resource servicebusauthrule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-06-01-preview' existing = {
  name: serviceBusAuthRule
  parent: servicebusnamespace
}



resource inputbinding1 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'inputbinding1'
  parent: environment
  properties: {
    componentType: 'bindings.azure.storagequeues'
    version: 'v1'
    metadata: [
      {
        name: 'storageAccount'
        secretRef: storageAccountNameRef
      }
      {
        name: 'storageAccessKey'
        secretRef: storageAccountKeyRef
      }
      {
        name: 'queue'
        value: storageQueueInputName
      }
      {
        name: 'decodeBase64'
        value: 'false'
      }
    ]
    scopes: [
      'mf-bindings'
    ]
    secrets: [
      {
        name: storageAccountNameRef
        value: sa.name
      }
      {
        name: storageAccountKeyRef
        value: listKeys(sa.id, sa.apiVersion).keys[0].value
      }
    ]
  }
}

resource outputbinding1 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'outputbinding1'
  parent: environment
  properties: {
    componentType: 'bindings.azure.storagequeues'
    version: 'v1'
    metadata: [
      {
        name: 'storageAccount'
        secretRef: storageAccountNameRef
      }
      {
        name: 'storageAccessKey'
        secretRef: storageAccountKeyRef
      }
      {
        name: 'queue'
        value: storageQueueOutputName
      }
      {
        name: 'decodeBase64'
        value: 'false'
      }
    ]
    scopes: [
      'mf-bindings'
    ]
    secrets: [
      {
        name: storageAccountNameRef
        value: sa.name
      }
      {
        name: storageAccountKeyRef
        value: listKeys(sa.id, sa.apiVersion).keys[0].value
      }
    ]
  }
}

resource inputbinding2 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'inputbinding2'
  parent: environment
  properties: {
    componentType: 'bindings.azure.servicebusqueues'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        secretRef: serviceBusConnectionStringRef
      }
      {
        name: 'queueName'
        value: serviceBusInputQueueName
      }
    ]
    scopes: [
      'mf-bindings'
    ]
    secrets: [
      {
        name: serviceBusConnectionStringRef
        value: listKeys(servicebusauthrule.id, servicebusauthrule.apiVersion).primaryConnectionString
      }
    ]
  }
}

resource outputbinding2 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'outputbinding2'
  parent: environment
  properties: {
    componentType: 'bindings.azure.servicebusqueues'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        secretRef: serviceBusConnectionStringRef
      }
      {
        name: 'queueName'
        value: serviceBusOutputQueueName
      }
    ]
    scopes: [
      'mf-bindings'
    ]
    secrets: [
      {
        name: serviceBusConnectionStringRef
        value: listKeys(servicebusauthrule.id, servicebusauthrule.apiVersion).primaryConnectionString
      }
    ]
  }
}

resource statestore 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'statestore'
  parent: environment
  properties: {
    componentType: 'state.azure.blobstorage'
    version: 'v1'
    metadata: [
      {
          name: 'accountName'
          value: sa.name
      }
      {
          name: 'accountKey'
          secretRef: storageAccountKeyRef
      }
      {
          name: 'containerName'
          value: 'test'
      }
    ]
    scopes: [
      'mf-bindings'
    ]
    secrets: [
      {
        name: storageAccountKeyRef
        value: listKeys(sa.id, sa.apiVersion).keys[0].value
      }
    ]
  }
}


/* 
Definition for the Azure Container Apps Container App.

This contains the bulk of the template, including container image details, authorization details for the Azure Container Registry, scaling thresholds, secret references, DAPR configuration and KEDA configuration.
*/

resource containerApp 'Microsoft.App/containerapps@2022-01-01-preview' = {
  name: containerAppServiceAppName
  tags: tags
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'single'
      ingress:{
        external:true
        targetPort:5000
      } 
      registries: [
        {
          server: acrLoginServerName
          username: acr.name
          passwordSecretRef: containerRegistryPasswordRef
        }
      ]
      dapr: {
        enabled: true
        appPort: 5000
        appId: 'mf-bindings'
      }
      secrets: [
        {
          name: containerRegistryPasswordRef
          value: listCredentials(acr.id, acr.apiVersion).passwords[0].value
        }
        {
          name: serviceBusConnectionStringRef
          value: listKeys(servicebusauthrule.id, servicebusauthrule.apiVersion).primaryConnectionString
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${acrLoginServerName}/${containerAppImage}'
          name: containerAppServiceAppName
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: [
          {
            name: 'queue-based-autoscaling'
            custom: {
              type: 'azure-servicebus'
              metadata: {
                queueName: serviceBusInputQueueName
                messageCount: '5'
              }
              auth: [
                {
                  secretRef: serviceBusConnectionStringRef
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
}

