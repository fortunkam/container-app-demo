# Container App Deployment Scripts

The script [./deploy.sh]() can be used to deploy all the necessary resources to get the app up and running in a container app.

This deploys...

* a Log analytics workspace
* application insights
* container registry
* storage account with a couple of queues
* service bus namespace with a couple of queues
* a kube environment
* a container app

You will need to have the appropriate permissions to run this in your environments (Contributor)