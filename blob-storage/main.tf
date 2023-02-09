terraform {

  required_version = ">=1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

}

provider "azurerm" {
  features {}
}

# Permissions for SAS token https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-user-delegation-sas-create-cli#assign-permissions-with-azure-rbac
data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "example" {
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.incubator2023.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.example.object_id
}

# Actual object storage bucket:
resource "azurerm_resource_group" "incubator2023" {
  name     = "snowmelt"
  location = "westeurope"
}

resource "azurerm_storage_account" "incubator2023" {
  name                     = "snowmelt"
  resource_group_name      = azurerm_resource_group.incubator2023.name
  location                 = azurerm_resource_group.incubator2023.location
  allow_blob_public_access = true
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "incubator2023" {
  name                  = "snowmelt"
  storage_account_name  = azurerm_storage_account.incubator2023.name
  container_access_type = "blob"
}
