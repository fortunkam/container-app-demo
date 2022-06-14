param prefix string = 'cappmf'

var storageAccountNameRef = 'storage-account-name'
var storageAccountKeyRef = 'storage-account-key'
var environmentName = '${prefix}-env'

var storageAccountName = '${prefix}${uniqueString(resourceGroup().id)}'

param storageQueueInputName string = 'ca-sa-queue-input'
param storageQueueOutputName string = 'ca-sa-queue-output'

var daprScope = 'daprreadwritequeue'

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName
}
// Definition for the existing storage account
resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource readqueue 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'readqueue'
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
      daprScope
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

resource writequeue 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'writequeue'
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
      daprScope
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
