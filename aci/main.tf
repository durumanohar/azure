provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "aci-example-rg"
  location = "West US"
}

resource "azurerm_virtual_network" "example" {
  name                = "aci-vnet-example"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_subnet" "example" {
  name                 = "aci-subnet-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
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
    type = "Private"
    subnet_id = azurerm_subnet.example.id
  }
}

