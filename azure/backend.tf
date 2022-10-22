terraform {
  required_version = ">= 1.1.0"

  cloud {
    organization = "seeu-blend"

    workspaces {
      name = "example-azure"
    }
  }

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.5.0"
    }
  }
}