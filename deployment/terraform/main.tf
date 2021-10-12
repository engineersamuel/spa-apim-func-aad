terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.51.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.location
}

resource "random_uuid" "ad_backend_hello_world_scope_id" {}