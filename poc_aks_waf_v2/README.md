# Azure Terraform PoC (AKS / Application Gateway / WAF version 2)

[![MIT Licensed](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)
[![Powered by Modus_Create](https://img.shields.io/badge/powered_by-Modus_Create-blue.svg?longCache=true&style=flat&logo=data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMzIwIDMwMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBkPSJNOTguODI0IDE0OS40OThjMCAxMi41Ny0yLjM1NiAyNC41ODItNi42MzcgMzUuNjM3LTQ5LjEtMjQuODEtODIuNzc1LTc1LjY5Mi04Mi43NzUtMTM0LjQ2IDAtMTcuNzgyIDMuMDkxLTM0LjgzOCA4Ljc0OS01MC42NzVhMTQ5LjUzNSAxNDkuNTM1IDAgMCAxIDQxLjEyNCAxMS4wNDYgMTA3Ljg3NyAxMDcuODc3IDAgMCAwLTcuNTIgMzkuNjI4YzAgMzYuODQyIDE4LjQyMyA2OS4zNiA0Ni41NDQgODguOTAzLjMyNiAzLjI2NS41MTUgNi41Ny41MTUgOS45MjF6TTY3LjgyIDE1LjAxOGM0OS4xIDI0LjgxMSA4Mi43NjggNzUuNzExIDgyLjc2OCAxMzQuNDggMCA4My4xNjgtNjcuNDIgMTUwLjU4OC0xNTAuNTg4IDE1MC41ODh2LTQyLjM1M2M1OS43NzggMCAxMDguMjM1LTQ4LjQ1OSAxMDguMjM1LTEwOC4yMzUgMC0zNi44NS0xOC40My02OS4zOC00Ni41NjItODguOTI3YTk5Ljk0OSA5OS45NDkgMCAwIDEtLjQ5Ny05Ljg5NyA5OC41MTIgOTguNTEyIDAgMCAxIDYuNjQ0LTM1LjY1NnptMTU1LjI5MiAxODIuNzE4YzE3LjczNyAzNS41NTggNTQuNDUgNTkuOTk3IDk2Ljg4OCA1OS45OTd2NDIuMzUzYy02MS45NTUgMC0xMTUuMTYyLTM3LjQyLTEzOC4yOC05MC44ODZhMTU4LjgxMSAxNTguODExIDAgMCAwIDQxLjM5Mi0xMS40NjR6bS0xMC4yNi02My41ODlhOTguMjMyIDk4LjIzMiAwIDAgMS00My40MjggMTQuODg5QzE2OS42NTQgNzIuMjI0IDIyNy4zOSA4Ljk1IDMwMS44NDUuMDAzYzQuNzAxIDEzLjE1MiA3LjU5MyAyNy4xNiA4LjQ1IDQxLjcxNC01MC4xMzMgNC40Ni05MC40MzMgNDMuMDgtOTcuNDQzIDkyLjQzem01NC4yNzgtNjguMTA1YzEyLjc5NC04LjEyNyAyNy41NjctMTMuNDA3IDQzLjQ1Mi0xNC45MTEtLjI0NyA4Mi45NTctNjcuNTY3IDE1MC4xMzItMTUwLjU4MiAxNTAuMTMyLTIuODQ2IDAtNS42NzMtLjA4OC04LjQ4LS4yNDNhMTU5LjM3OCAxNTkuMzc4IDAgMCAwIDguMTk4LTQyLjExOGMuMDk0IDAgLjE4Ny4wMDguMjgyLjAwOCA1NC41NTcgMCA5OS42NjUtNDAuMzczIDEwNy4xMy05Mi44Njh6IiBmaWxsPSIjRkZGIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiLz4KPC9zdmc+)](https://moduscreate.com)

AKS URL: [https://azure.microsoft.com/en-us/services/kubernetes-service/](https://azure.microsoft.com/en-us/services/kubernetes-service/)

- [Objective](#Objective)
- [Prerequisites](#Prerequisites)
- [Tutorial](#Tutorial)
- [Modus Create](#modus-create)
- [Licensing](#licensing)

## Objective
* Deploy an AKS - Azure Container Service
* Enable WAF v2
* WAF rule 931130 will be disabled as an example
* Access outside USA and Brazil will be blocked as an example
* Wordpress image from dockerhub will be deployed and configured to run at AKS
* NGINX will be used as ingress controller
* Create the resources using Terraform

## Prerequisites

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed (made with Azure CLI `2.16.0`)
* HashiCorp [Terraform](https://terraform.io/downloads.html) installed (made with Terraform version: `0.14.2`)
* [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html) (made with azurerm version: `2.41.0`)
* [helm](https://helm.sh/docs/intro/install/) (made with helm version: `3.5`)

## Tutorial

Creating a Service Principal

```bash
az login
az ad sp create-for-rbac --role="Owner" -n "poc-terraform" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
```

Expected output:

```bash
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-xxxx-xx-xx-xx-xx-xx",
  "name": "http://azure-cli-xxxx-xx-xx-xx-xx-xx",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

`appId` = CLIENT_ID, 
`password` = CLIENT_SECRET, 
`tenant` = TENANT_ID

Export environment variables to configure the [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) Terraform provider.

```bash
export ARM_SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
export ARM_TENANT_ID="TENANT_ID"
export ARM_CLIENT_ID="CLIENT_ID"
export ARM_CLIENT_SECRET="CLIENT_SECRET"
az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID
```
Note: If you are using Windows replace "export" to "$ENV:" at powershell

Run Terraform init and plan at \deployments\dev folder.

```bash
terraform init
terraform plan
terraform apply
```

After the terraform apply finishes you should run the following commands at bash or powershell:

```bash
#get-credentials to access the AKS
az aks get-credentials --resource-group poc06-rg-us-dev --name poc06-aks-01-us-dev --overwrite-existing

#create the namespace infrastructure and does not return error if it already exists
kubectl create namespace infrastructure --dry-run=client -o yaml | kubectl apply -f -

#go to yaml files folder
cd poc_aks_waf\aks_yaml

#use helm to install NGINX
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx --namespace infrastructure -f internal-ingress.yaml --set controller.replicaCount=2

#create the namespace app01 and does not return error if it already exists
kubectl create namespace app01 --dry-run=client -o yaml | kubectl apply -f -

#run wordpress at AKS
kubectl create -f deployment.yaml -n app01
kubectl create -f service.yaml -n app01
kubectl create -f ingress.yaml -n app01
```

After running the command lines you can go to the Azure Portal  [Azure Portal](https://portal.azure.com/), get the Application Gateway address and access it using your browser.  
The IP will be at: **"Application gateways > poc-appgw-06-us-dev > Frontend public IP address"**

Normal access: http://xxx.xxx.xxx.xxx  
Malicious URL will be blocked by WAF: http://xxx.xxx.xxx.xxx?injection=--insert  
Access outside USA and Brazil will be blocked by WAF  

## Modus Create

[Modus Create](https://moduscreate.com) is a digital product consultancy. We use a distributed team of the best talent in the world to offer a full suite of digital product design-build services; ranging from consumer facing apps, to digital migration, to agile development training, and business transformation.

<a href="https://moduscreate.com/?utm_source=labs&utm_medium=github&utm_campaign=Azure_Terraform_PoC"><img src="https://res.cloudinary.com/modus-labs/image/upload/h_80/v1533109874/modus/logo-long-black.svg" height="80" alt="Modus Create"/></a>
<br />

This project is part of [Modus Labs](https://labs.moduscreate.com/?utm_source=labs&utm_medium=github&utm_campaign=Azure_Terraform_PoC).

<a href="https://labs.moduscreate.com/?utm_source=labs&utm_medium=github&utm_campaign=Azure_Terraform_PoC"><img src="https://res.cloudinary.com/modus-labs/image/upload/h_80/v1531492623/labs/logo-black.svg" height="80" alt="Modus Labs"/></a>

# Licensing

This project is [MIT licensed](./LICENSE).

