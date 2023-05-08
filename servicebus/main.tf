# Define the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "West Europe"
}

# Create an Azure Service Bus namespace
resource "azurerm_servicebus_namespace" "example" {
  name                = "example-service-bus-namespace"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
}

# Create a Service Bus topic
resource "azurerm_servicebus_topic" "example" {
  name                = "example-topic"
  namespace_name      = azurerm_servicebus_namespace.example.name
  resource_group_name = azurerm_resource_group.example.name
}

# Create a Service Bus subscription
resource "azurerm_servicebus_subscription" "example" {
  name                = "example-subscription"
  namespace_name      = azurerm_servicebus_namespace.example.name
  resource_group_name = azurerm_resource_group.example.name
  topic_name          = azurerm_servicebus_topic.example.name
}
