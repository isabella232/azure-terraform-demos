output "private_ip_address" {
  value = join(",", azurerm_network_interface.network_interface[*].private_ip_address)
}
