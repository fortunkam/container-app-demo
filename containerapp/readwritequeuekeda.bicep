param prefix string = 'cappmf'

// Also take an object as an input for the tags parameter. This is used to cascade resource tags to all resources.
param tags object = {}

// Set location as a parameter with a default of the Resource Group Location. This allows for overrides if needed, and is a templating best practice.
param location string = resourceGroup().location

var containerImageName = 'daprqueue'
var containerAppName = 'daprqueue'
var acrName = '${prefix}acr'
var acrLoginServerName = '${prefix}acr.azurecr.io'
var environmentName = '${prefix}-env'
var managedIdentityName = '${prefix}-managed-identity'
var storageAccountName = '${prefix}${uniqueString(resourceGroup().id)}'
var storageAccountConnectionStringRef = 'storage-connection-string'

param storageQueueInputName string = 'ca-sa-queue-input'

var daprScope = 'daprreadwritequeue'

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: acrName
}

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName
}

resource managedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' existing = {
  name: managedIdentityName
}

resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource containerApp 'Microsoft.App/containerapps@2022-03-01' = {
  name: containerAppName
  tags: tags
  location: location
  identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${managedidentity.id}': {}
      }
  }

  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'single'
      ingress:{
        external:false
        targetPort:5000
      } 
      registries: [
        {
          server: acrLoginServerName
          identity: managedidentity.id
        }
      ]
      dapr: {
        enabled: true
        appPort: 5000
        appId: daprScope
      }
      secrets: [
        {
          name:storageAccountConnectionStringRef
          value: 'DefaultEndpointsProtocol=https;AccountName=${sa.name};AccountKey=${listKeys(sa.id, sa.apiVersion).keys[0].value};EndpointSuffix=core.windows.net'
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${acrLoginServerName}/${containerImageName}:v1'
          name: '${containerAppName}-v1'
        }
      ]
      revisionSuffix: 'v3'
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            name: 'queue-based-autoscaling'
            custom: {
              type: 'azure-queue'
              metadata: {
                queueName: storageQueueInputName
                queueLength: '1'
                accountName: sa.name
              }
              auth: [{
                secretRef: storageAccountConnectionStringRef
                triggerParameter: 'connection'
              }]
            }
          }
        ]
      }
    }
  }
}
