# CONFIGURATION
terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.10.0"
    }
  }   
}
provider "azurerm" {
  features {}
}


# VARIABLES
variable "resource_group_name" {
  description = "The name of the resource group"
}
variable "location" {
  description = "The name of the Azure location"
  default = "West Europe"
  validation { # TF 0.13
    condition = can(index(["westeurope","westus"], var.location) >= 0)
    error_message = "The location must be westeurope or westus."
  }
}
variable "application_name" {
  description = "The name of application"
}
variable "environment_name" {
  description = "The name of environment"
}
variable "country_code" {
  description = "The country code (FR-US-...)"
}


# LOCAL VARIABLES
locals {
  resource_name = "${var.application_name}-${var.environment_name}-${var.country_code}"
}


# OUTPUTS
output "webapp_name" {
  description = "output Name of the webapp"
  value = azurerm_app_service.app.name
}



# RESOURCES
resource "azurerm_resource_group" "rg" {
  name     = "RG-${local.resource_name}"
  location = var.location
}
resource "azurerm_public_ip" "pip" {
  name                         = "IP-${local.resource_name}"
  location                     = "West Europe"
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = "Dynamic"
  domain_name_label            = "bookdevops"
}
resource "azurerm_app_service" "app" {
  name                = "${var.app_name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service.app.id
}