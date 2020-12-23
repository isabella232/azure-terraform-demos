# Azure Terraform POC (Application Gateway / WAF / TLS)

## Objective
* Deploy 2 Virtual Machines with Apache web-server installed
* Deploy Application Gateway/WAF and balance the access between the VMs (round-robin algorithm will be used to route the requests between healthy VMs)
* WAF rule 931130 will be disabled as an example
* Create the resources using Terraform
* SSL/TLS will implemented at this time at Application Gateway (Lets Encrypt)

![alt text](https://github.com/ModusCreateOrg/azure-terraform-demos/blob/master/poc_application_gateway_waf_ssl/images/architecture.png?raw=true)

## Prerequisites

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed (made with Azure CLI `2.16.0`)
* HashiCorp [Terraform](https://terraform.io/downloads.html) installed (made with Terraform version: `0.14.2`)
* [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html) (made with azurerm version: `2.40.0`)

To get the SSL/TLS working in a domain I registered a domain called "zipweb.xyz" at namecheap.com (It costs USD 1.00/yr)  

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

`appId` = CLIENT_ID  
`password` = CLIENT_SECRET  
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
terraform plan -var 'azure_client_secret=CLIENT_SECRET'
terraform apply -var 'azure_client_secret=CLIENT_SECRET'
```

The fist time you run the terraform apply you will have the following error: 
```bash
Error: error creating certificate: error: one or more domains had a problem:
[zipweb.xyz] [zipweb.xyz] acme: error presenting token: 2 errors occurred:
        * azure: unexpected response code 'SERVFAIL' for _acme-challenge.zipweb.xyz.
        * error encountered while presenting token for DNS challenge: azure: unexpected response code 'SERVFAIL' for _acme-challenge.zipweb.xyz.
```

It will happen because Lets Encrypt will try to validate the domain but the domain is not pointing to Azure DNS servers.  
Since you already runned terraform it created a DNS zone at Azure.  

![alt text](https://github.com/ModusCreateOrg/azure-terraform-demos/blob/master/poc_application_gateway_waf_ssl/images/azure_dns.png?raw=true)

Now you must go to your registrar (namecheap.com in this example) and update the DNS records.  

![alt text](https://github.com/ModusCreateOrg/azure-terraform-demos/blob/master/poc_application_gateway_waf_ssl/images/namecheap_dns.png?raw=true)

After updating the DNS at registrar you should wait until the new DNS server start working. You can check using the following command line:
```bash
nslookup -type=ns zipweb.xyz
```

If you have an answer like the one below that contains azure name servers you can run a terraform apply again and you will not have errors.
```bash
Server:  UnKnown
Address:  192.168.1.1

Non-authoritative answer:
zipweb.xyz      nameserver = ns2-08.azure-dns.net
zipweb.xyz      nameserver = ns4-08.azure-dns.info
zipweb.xyz      nameserver = ns3-08.azure-dns.org
zipweb.xyz      nameserver = ns1-08.azure-dns.com
```

```bash
terraform apply -var 'azure_client_secret=CLIENT_SECRET'
```
*Note: Creating an Application gateway can take up to 20/25 minutes.*  

After the terraform apply finishes you can access the domain using the browser "zipweb.xyz" and you will have a valid SLL/TLS certificate working.