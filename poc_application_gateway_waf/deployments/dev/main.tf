# https://github.com/hashicorp/terraform/releases
terraform {
  required_version = "~> 0.14.2"
}

provider "azurerm" {
  features {
  }
}

# Create a resource group for the platform runtime
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
  custom_data                                    = file("azure-user-data.sh")
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
  name                    = "${var.project_name}-appgw-01-${var.region}-${var.stage}"
  subnet_name             = "${var.project_name}-snet-appgw-01-${var.region}-${var.stage}"
  resource_group_name     = module.resource_group_01.name
  location                = module.resource_group_01.location
  vnet_id                 = module.virtual_network.id
  vnet_name               = module.virtual_network.name
  vnet_address_space      = [var.waf_01_subnet_address_prefix]
  backend_port            = 80
  backend_request_timeout = 5
  ip_addresses            = module.linux_virtual_machine.private_ip_address
}