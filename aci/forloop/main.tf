provider "azurerm" {
  features {}
}

data "azurerm_container_registry" "acr" {
  name                = "my-container-registry"
  resource_group_name = "my-resource-group"
}

resource "null_resource" "acr_image_operations" {
  for_each = data.azurerm_container_registry.acr.images

  triggers = {
    image_name = each.value.name
  }

  provisioner "local-exec" {
    command = <<EOT
      # Example operation
      echo "Image Name: ${each.value.name}"
      # Add more operations here
    EOT
  }
}
