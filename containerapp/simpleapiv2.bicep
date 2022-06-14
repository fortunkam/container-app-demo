param prefix string = 'cappmf'

// Also take an object as an input for the tags parameter. This is used to cascade resource tags to all resources.
param tags object = {}

// Set location as a parameter with a default of the Resource Group Location. This allows for overrides if needed, and is a templating best practice.
param location string = resourceGroup().location

var containerImageName = 'simpleapi'
var simpleApiContainerAppName = 'simpleapi'
var acrName = '${prefix}acr'
var acrLoginServerName = '${prefix}acr.azurecr.io'
var environmentName = '${prefix}-env'
var managedIdentityName = '${prefix}-managed-identity'

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: acrName
}

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName
}

resource managedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' existing = {
  name: managedIdentityName
}

resource containerApp 'Microsoft.App/containerapps@2022-03-01' = {
  name: simpleApiContainerAppName
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
      activeRevisionsMode: 'multiple'

      ingress:{
        external:true
        targetPort:5000
        traffic: [
          {
            label : 'v1'
            revisionName: '${simpleApiContainerAppName}--v1'
            weight: 50
          }
          {
            label : 'v2'
            revisionName: '${simpleApiContainerAppName}--v2'
            weight: 50
          }
        ]
      } 
      registries: [
        {
          server: acrLoginServerName
          identity: managedidentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          image: '${acrLoginServerName}/${containerImageName}:v2'
          name: '${simpleApiContainerAppName}-v2'
        }
      ]
      revisionSuffix: 'v2'
    }
  }
}
