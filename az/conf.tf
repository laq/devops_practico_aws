provider "azurerm" {
  version = "~> 1.4"
}
resource "azurerm_resource_group" "rg" {
        name = "testResourceGroup"
        location = "westus"
}