resource "azurerm_api_management" "api_management" {
  name                = "blend-${var.project}-api-management"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  publisher_name      = "SEEU"
  publisher_email     = "bh29568@seeu.edu.mk"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_api" "api_management_api" {
  name                  = "blend-${var.project}-api-management-api"
  resource_group_name   = azurerm_resource_group.resource_group.name
  api_management_name   = azurerm_api_management.api_management.name
  revision              = "1"
  display_name          = "Test API"
  path                  = ""
  protocols             = ["https"]
  subscription_required = false
  service_url           = "https://${azurerm_windows_function_app.app.name}.azurewebsites.net/api"
}

resource "azurerm_api_management_api_operation" "api_management_api_operation" {
  operation_id        = "blend-${var.project}-api-management-api-operation"
  api_name            = azurerm_api_management_api.api_management_api.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name
  display_name        = "Test API endpoint"
  method              = "POST"
  url_template        = "/users"
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "blend-${var.project}-api-management-log-analytics-workspace-diagnostic-setting"
  target_resource_id         = azurerm_api_management.api_management.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  log {
    category = "GatewayLogs"
  }

  metric {
    category = "AllMetrics"
  }
}