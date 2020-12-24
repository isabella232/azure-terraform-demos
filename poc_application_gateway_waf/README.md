# Azure Terraform POC (Application Gateway / WAF)

## Objective
* Deploy 2 Virtual Machines with Apache web-server installed
* Deploy Application Gateway/WAF and balance the access between the VMs (round-robin algorithm will be used to route the requests between healthy VMs)
* WAF rule 931130 will be disabled as an example
* Create the resources using Terraform
* SSL/TLS will not be implemented at this time

![alt text](https://github.com/ModusCreateOrg/azure-terraform-demos/blob/master/poc_application_gateway_waf/images/architecture.png?raw=true)

## Prerequisites

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed (made with Azure CLI `2.16.0`)
* HashiCorp [Terraform](https://terraform.io/downloads.html) installed (made with Terraform version: `0.14.2`)
* [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html) (made with azurerm version: `2.40.0`)

## Tutorial

Creating a Service Principal

```bash
az login
az ad sp create-for-rbac --role="Contributor" -n "poc-terraform" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
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

*Note: Creating an Application gateway can take up to 20/25 minutes.*

After the terraform apply finishes you can go to the Azure Portal  [Azure Portal](https://portal.azure.com/), get the Application Gateway IP address and access it using your browser at port 80 (http). The IP will be at: "Application gateways > poc-appgw-01-us-dev > Frontend public IP address"
