module "frontdoor" {
  source  = "Azure/frontdoor/azurerm"
  version = "1.0.0"

  resource_group_name = "example-resource-group"
  frontdoor_name      = "example-frontdoor"
  location            = "eastus"

  frontend_endpoints = [
    {
      name                    = "example-frontend"
      host_name               = "example.com"
      session_affinity_enabled = true
      session_affinity_ttl     = 1200
      enabled                 = true
      custom_https_provisioning_state = "Disabled"
      custom_https_configuration = []
    }
  ]

  backend_pools = [
    {
      name          = "example-backend-pool"
      load_balancing = "Weighted"
      backend_addresses = [
        {
          fqdn                 = "example-backend.com"
          enabled              = true
          private_link_enabled = false
        }
      ]
    }
  ]

  routing_rules = [
    {
      name              = "example-routing-rule"
      frontend_endpoints = ["example-frontend"]
      accepted_protocols = ["Https"]
      patterns_to_match  = ["/api/*"]
      forwarding_configuration = {
        backend_pool_name = "example-backend-pool"
        backend_protocol  = "Https"
        routing_rule_type = "Basic"
      }
    }
  ]
}
