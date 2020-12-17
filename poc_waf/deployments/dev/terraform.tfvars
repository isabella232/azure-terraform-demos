################################################################################
# Common variables
################################################################################
project_name = "poc"
stage        = "dev"
region       = "us"
location     = "eastus"

################################################################################
# Variables for platform
################################################################################
vnet_01_address_space        = "10.1.0.0/16"   #65534 hosts - 10.1.0.1 to 10.1.255.254
vm_01_subnet_address_prefix  = "10.1.1.0/24"   #254 hosts - 10.1.1.1 to 10.1.1.254
waf_01_subnet_address_prefix = "10.1.255.0/28" #14 hosts - 10.1.255.1 to 10.1.255.14

