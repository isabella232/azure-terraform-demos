# Create a network_interface
resource "azurerm_network_interface" "network_interface" {
  count               = var.qty
  name                = "${var.network_interface_name}-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = var.ip_configuration_subnet_id
    private_ip_address_allocation = var.ip_configuration_private_ip_address_allocation
  }
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  count                           = var.qty
  name                            = "${var.name}-${count.index}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = var.disable_password_authentication
  network_interface_ids           = [element(azurerm_network_interface.network_interface.*.id, count.index)]
  custom_data                     = base64encode(replace(var.custom_data, "#XXX#", "${var.name}-${count.index}"))

  os_disk {
    name                 = "${var.os_disk_name}-${count.index}"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference_publisher
    offer     = var.source_image_reference_offer
    sku       = var.source_image_reference_sku
    version   = var.source_image_reference_version
  }
}
