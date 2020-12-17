# Azure Terraform POC (Application Gateway / WAF)
* Deploy one Virtual Machine with Apache web-server installed
* Deploy Application Gateway / WAF
* WAF rule 931130 will be disabled as an example

This repository contains HashiCorp Terraform configuration required to create resources at Azure.

## Prerequisites

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed.
* HashiCorp [Terraform](https://terraform.io/downloads.html) installed.
* Made with Terraform version: `0.14.2`
* [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html) version: `2.40.0`

## Tutorial

Generate Azure client id and secret.

```bash
az login
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
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

`appId` = Client id.
`password` = Client secret.
`tenant` = Tenant id.

Export environment variables to configure the [Azure](https://www.terraform.io/docs/providers/azurerm/index.html) Terraform provider.

```bash
export ARM_SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
export ARM_TENANT_ID="TENANT_ID"
export ARM_CLIENT_ID="CLIENT_ID"
export ARM_CLIENT_SECRET="CLIENT_SECRET"
```
Note: If you are using Windows replace "export" to "$ENV:" at powershell

Run Terraform init and plan at \deployments\dev folder.

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

*Note: Creating an Application gateway can take up to 10/15 minutes.*

After the terraform apply finishes you can go to the Azure Portal  [Azure Portal](https://portal.azure.com/), get the Application Gateway IP address and access it using your browser at port 80 (http).
The IP will be at: "Application gateways > poc-appgw-01-us-dev > Frontend public IP address"
