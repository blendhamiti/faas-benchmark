resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project}-resource-group"
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "blend${var.project}storage"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "${var.project}-log-analytics-workspace"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_service_plan" "service_plan" {
  name                = "${var.project}-service-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${var.project}-app-insights"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  application_type    = "Node.JS"
}

resource "azurerm_windows_function_app" "app" {
  name                = "blend-${var.project}-function-app"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key

  service_plan_id = azurerm_service_plan.service_plan.id

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                          = "node",
    "AzureFunctionsJobHost__logging__logLevel__Default" = "Trace",
    "WEBSITE_NODE_DEFAULT_VERSION"                      = "~14",
    "WEBSITE_RUN_FROM_PACKAGE"                          = "https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.app_code.name}/${azurerm_storage_blob.app_code_blob.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
    "DB_HOST"                                           = "${azurerm_mysql_server.mysql_server.fqdn}",
    "DB_NAME"                                           = "${azurerm_mysql_database.mysql_database.name}",
    "DB_USER"                                           = "${azurerm_mysql_server.mysql_server.administrator_login}@${azurerm_mysql_server.mysql_server.name}",
    "DB_PASSWORD"                                       = "${azurerm_mysql_server.mysql_server.administrator_login_password}",
    "AZURE_STORAGE_CONNECTION_STRING"                   = "${azurerm_storage_account.storage_account.primary_connection_string}",
    "PROFILE_IMAGES_CONTAINER"                          = "${azurerm_storage_container.profile_images_container.name}",
    "THUMBNAILS_CONTAINER"                              = "${azurerm_storage_container.thumbnails_container.name}",
  }
  site_config {
    application_insights_key = azurerm_application_insights.app_insights.instrumentation_key
  }
}

data "archive_file" "app_file" {
  type        = "zip"
  source_dir  = "${path.module}/app"
  output_path = "${path.module}/app.zip"
}

resource "azurerm_storage_container" "app_code" {
  name                  = "app-code"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "app_code_blob" {
  name                   = "${filesha256(data.archive_file.app_file.output_path)}.zip"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.app_code.name
  type                   = "Block"
  source                 = data.archive_file.app_file.output_path
}

data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string
  container_name    = azurerm_storage_container.app_code.name

  start  = "2022-01-01T00:00:00Z"
  expiry = "2032-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}