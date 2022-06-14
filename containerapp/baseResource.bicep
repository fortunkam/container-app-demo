param location string = resourceGroup().location

param prefix string = 'cappmf'
param serviceBusInputQueueName string = 'ca-sb-queue-input'
param serviceBusOutputQueueName string = 'ca-sb-queue-output'
param storageQueueInputName string = 'ca-sa-queue-input'
param storageQueueOutputName string = 'ca-sa-queue-output'

var workspaceName = '${prefix}-log-analytics'
var appInsightsName = '${prefix}-app-insights'
var serviceBusName = '${prefix}-service-bus'
var serviceBusAuthRule = '${prefix}-service-bus-auth-rule'
var acrName = '${prefix}acr'
var managedIdentityName = '${prefix}-managed-identity'
param tags object = {} 
var storageAccountName = '${prefix}${uniqueString(resourceGroup().id)}'

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {}
  }
}

// Definition for the App Insights Resource
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
  }
}

//ACR
resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Storage Account

resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

// Storage Account Queue

resource queueservices 'Microsoft.Storage/storageAccounts/queueServices@2021-06-01' = {
  name: 'default'
  parent: sa
  properties: {
    cors: {
      corsRules: [
      ]
    }
  }
}

resource storageQueueInput 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-06-01' = {
  name: storageQueueInputName
  parent: queueservices
  properties: {
    metadata: {}
  }
}
resource storageQueueOutput 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-06-01' = {
  name: storageQueueOutputName
  parent: queueservices
  properties: {
    metadata: {}
  }
}

//Storage Table

resource tableservices 'Microsoft.Storage/storageAccounts/tableServices@2021-06-01' = {
  name: 'default'
  parent: sa
  properties: {
    cors: {
      corsRules: [
      ]
    }
  }
}

resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-06-01' = {
  name: 'daprstate'
  parent: tableservices
}

//Service Bus Namespace
resource servicebusnamespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: serviceBusName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

//Queue
resource servicebusqueueinput 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview' = {
  name: serviceBusInputQueueName
  parent: servicebusnamespace
  properties: {
  }
}

resource servicebusqueueoutput 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview' = {
  name: serviceBusOutputQueueName
  parent: servicebusnamespace
  properties: {
  }
}

resource servicebusauthrule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-06-01-preview' = {
  name: serviceBusAuthRule
  parent: servicebusnamespace
  properties: {
    rights: [
      'Manage'
      'Listen'
      'Send'
    ]
  }
}

resource managedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: managedIdentityName
  location: location
}

@description('This is the built-in acrPull role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource acrPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope:  subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, managedIdentityName, acrPullRoleDefinition.id)
  properties: {
    roleDefinitionId: acrPullRoleDefinition.id
    principalId: managedidentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
