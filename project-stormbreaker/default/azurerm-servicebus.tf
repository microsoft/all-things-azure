
resource "azurerm_servicebus_namespace" "stormbreaker-servicebus" {
  name                = "stormbreaker-servicebus${var.suffix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "Standard"
}

/* service bus queues */
resource "azurerm_servicebus_queue" "dispatch" {
  name         = "stormbreaker-dispatch"
  namespace_id = azurerm_servicebus_namespace.stormbreaker-servicebus.id

  enable_partitioning = true
}

resource "azurerm_servicebus_queue" "running" {
  name         = "stormbreaker-running"
  namespace_id = azurerm_servicebus_namespace.stormbreaker-servicebus.id

  enable_partitioning = true
}

resource "azurerm_servicebus_queue" "delete" {
  name         = "stormbreaker-delete"
  namespace_id = azurerm_servicebus_namespace.stormbreaker-servicebus.id

  enable_partitioning = true
}

# data "azurerm_user_assigned_identity" "managed-id" {
#   name                = "aks-user-assigned-managed-id"
#   resource_group_name = azurerm_resource_group.default.name
# }

resource "azurerm_role_assignment" "stormbreaker-servicebus" {
  scope                = azurerm_servicebus_namespace.stormbreaker-servicebus.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_user_assigned_identity.managed-id.principal_id
}