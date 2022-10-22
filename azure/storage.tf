resource "azurerm_storage_container" "profile_images_container" {
  name                  = "profile-images"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "thumbnails_container" {
  name                  = "thumbnails"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}