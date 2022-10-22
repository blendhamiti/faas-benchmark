terraform {
  required_version = ">= 1.1.0"

  cloud {
    organization = "seeu-blend"

    workspaces {
      name = "example-lambda"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}