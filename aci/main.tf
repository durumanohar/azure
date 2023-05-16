provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "aci-example-rg"
  location = "West US"
}

resource "azurerm_container_group" "example" {
  name                = "aci-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  os_type = "Linux"

  container {
    name   = "mycontainer"
    image  = "nginx"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address {
    type = "Public"
  }
}
