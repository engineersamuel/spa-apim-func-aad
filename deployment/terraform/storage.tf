resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.project}${var.environment}sto"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}