provider "azurerm" {
  features {}
}

variable "isolation_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

resource "azurerm_resource_group" "example" {
  name     = "aci-example-rg"
  location = "West US"
}

resource "azurerm_virtual_network" "example" {
  count               = length(var.isolation_zones)
  name                = "aci-vnet-${var.isolation_zones[count.index]}"
  address_space       = ["10.${count.index}.0.0/16"]
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_container_group" "example" {
  count               = length(var.isolation_zones)
  name                = "aci-example-${var.isolation_zones[count.index]}"
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
    type                = "Private"
    subnet_id           = azurerm_virtual_network.example[count.index].subnets[0].id
    private_ip_address_allocation = "Dynamic"
  }
}
