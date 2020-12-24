# Create an A record within an Azure DNS zone
resource "azurerm_dns_txt_record" "dns_txt_record" {
  name                = var.name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = var.ttl

  record {
    value = var.record
  }

}
