resource "azurerm_storage_account" "stormbreaker" {
  name                     = "stormbreakerstor${var.suffix}"
  location                 = azurerm_resource_group.default.location
  resource_group_name      = azurerm_resource_group.default.name
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "BlockBlobStorage"
  is_hns_enabled           = "true"
  nfsv3_enabled            = "true"
  
  network_rules {
    default_action         = "Deny"
    bypass                 = ["AzureServices", "Logging", "Metrics"]
    virtual_network_subnet_ids = [azurerm_subnet.stormbreaker-cluster.id]
    ip_rules = [data.http.myip.response_body]
  }
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = azurerm_storage_account.stormbreaker.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "storage_contributor" {
  scope                = azurerm_storage_account.stormbreaker.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "filesystem" {
  name               = "input"
  storage_account_id = azurerm_storage_account.stormbreaker.id
  depends_on         = [
    azurerm_role_assignment.storage_blob_data_owner,
    azurerm_role_assignment.storage_contributor,
    azurerm_storage_account.stormbreaker
  ]
}

resource "azurerm_storage_data_lake_gen2_filesystem" "filesystem-out" {
  name               = "output"
  storage_account_id = azurerm_storage_account.stormbreaker.id
  depends_on         = [
    azurerm_role_assignment.storage_blob_data_owner,
    azurerm_role_assignment.storage_contributor,
    azurerm_storage_account.stormbreaker
  ]
}

resource "azurerm_role_assignment" "stormbreaker-storage-account" {
  scope                = azurerm_storage_account.stormbreaker.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.managed-id.principal_id
}