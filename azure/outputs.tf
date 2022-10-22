output "function_app_name" {
  value       = azurerm_windows_function_app.app.name
  description = "Deployed function app name"
}

output "api_management_gateway_url" {
  value       = azurerm_api_management.api_management.gateway_url
  description = "API management gateway URL"
}