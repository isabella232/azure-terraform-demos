# https://github.com/hashicorp/terraform/releases
terraform {
  required_version = "~> 0.14.2"
}

provider "azurerm" {
  features {
  }
}

# Create a resource group
module "resource_group_01" {
  source   = "../../modules/resource_group/"
  name     = "${var.project_name}-rg-${var.region}-${var.stage}"
  location = var.location
}

# Create a Virtual Network
module "virtual_network" {
  source              = "../../modules/virtual_network/"
  name                = "${var.project_name}-vnet-01-${var.region}-${var.stage}"
  resource_group_name = module.resource_group_01.name
  location            = module.resource_group_01.location
  address_space       = [var.vnet_01_address_space]
}

# Create Subnet
module "subnet_vm" {
  source               = "../../modules/subnet/"
  name                 = "${var.project_name}-snet-01-${var.region}-${var.stage}"
  resource_group_name  = module.resource_group_01.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = var.vm_01_subnet_address_prefix
}

# Create Virtual Machine
module "linux_virtual_machine" {
  source                                         = "../../modules/linux_virtual_machine/"
  qty                                            = 2
  name                                           = "${var.project_name}-vm-01-${var.region}-${var.stage}"
  location                                       = module.resource_group_01.location
  resource_group_name                            = module.resource_group_01.name
  size                                           = "Standard_B1ls"
  admin_username                                 = "poc_admin"
  admin_password                                 = "This~is#a!P0C" # password explicity just for a POC - do not use in production env!
  disable_password_authentication                = false
  os_disk_name                                   = "${var.project_name}-vm-01-disk-${var.region}-${var.stage}"
  os_disk_caching                                = "ReadWrite"
  os_disk_storage_account_type                   = "Standard_LRS"
  source_image_reference_publisher               = "Canonical"
  source_image_reference_offer                   = "UbuntuServer"
  source_image_reference_sku                     = "18.04-LTS"
  source_image_reference_version                 = "latest"
  custom_data                                    = base64encode(file("azure-user-data.sh"))
  network_interface_name                         = "${var.project_name}-ni-01-${var.region}-${var.stage}"
  ip_configuration_name                          = "${var.project_name}-vm-01-ip-${var.region}-${var.stage}"
  ip_configuration_subnet_id                     = module.subnet_vm.id
  ip_configuration_private_ip_address_allocation = "Dynamic"

}

# Create an Application Gateway / WAF
module "application_gateway" {
  source = "../../modules/application_gateway/"

  # Public IP
  pip_name              = "${var.project_name}-appgw-pip-01-${var.region}-${var.stage}"
  pip_domain_name_label = "${var.stage}-${var.project_name}"
  pip_ip_version        = "IPv4"

  # Application Gateway (aka Web Application Firewall)
  name                            = "${var.project_name}-appgw-01-${var.region}-${var.stage}"
  subnet_name                     = "${var.project_name}-snet-appgw-01-${var.region}-${var.stage}"
  resource_group_name             = module.resource_group_01.name
  location                        = module.resource_group_01.location
  vnet_id                         = module.virtual_network.id
  vnet_name                       = module.virtual_network.name
  vnet_address_space              = [var.waf_01_subnet_address_prefix]
  backend_port                    = 80
  backend_request_timeout         = 10
  ip_addresses                    = module.linux_virtual_machine.private_ip_address
  frontend_tls_certificate        = acme_certificate.certificate.certificate_p12
}

# Create a DNS zone
resource "azurerm_dns_zone" "dns_zone" {
  name                = var.domain_url
  resource_group_name = module.resource_group_01.name
}

# Create an A record
module "dns_a_record_core" {
  source              = "../../modules/dns_a_record/"
  name                = "@"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = module.resource_group_01.name
  ttl                 = 0
  records             = [data.azurerm_public_ip.public_ip.ip_address]
}

# Create TLS/SSL using lets encrypt
provider "acme" {
  #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory" 
}

# Create the private key for the registration
resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

# Create the private key for the certificate
resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

# Create an ACME registration 
resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = var.ssl_email
}

# Create a certificate
resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = var.domain_url

  dns_challenge {
    provider = "azure"
    config = {
      AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
      AZURE_CLIENT_ID       = data.azurerm_client_config.current.client_id
      AZURE_CLIENT_SECRET   = var.azure_client_secret
      AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
      AZURE_RESOURCE_GROUP  = module.resource_group_01.name
    }
  }
  depends_on = [azurerm_dns_zone.dns_zone]
}

# Read data from the current subscription for later use (e.g.: when Tenant ID is needed)
data "azurerm_client_config" "current" {}

# Read data from public ip from application gateway
data "azurerm_public_ip" "public_ip" {
  name                = module.application_gateway.pip_name
  resource_group_name = module.resource_group_01.name
  # Explicit dependency is needed! Otherwise, when creating the AppGW for the firt time, the dependency is not respected and thus terraform apply fails
  depends_on = [module.application_gateway]
}