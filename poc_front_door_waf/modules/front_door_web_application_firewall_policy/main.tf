resource "azurerm_frontdoor_firewall_policy" "frontdoor_firewall_policy" {
  name                = var.name
  resource_group_name = var.resource_group_name
  enabled             = true
  mode                = "Prevention"

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "1.1"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
  }

  custom_rule {
    name     = "${var.name}rule1"
    priority = 1
    type     = "MatchRule"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "GeoMatch"
      negation_condition = true
      match_values       = ["US", "BR"]
    }

    action = "Block"
  }
}