terraform {
  required_version = ">= 1.1.0"

  cloud {
    organization = "seeu-blend"

    workspaces {
      name = "example-gcp"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.25.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}