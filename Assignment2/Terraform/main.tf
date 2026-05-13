terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_servicebus_namespace" "main" {
  name                = var.service_bus_namespace_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "main" {
  name         = var.service_bus_queue_name
  namespace_id = azurerm_servicebus_namespace.main.id
}

resource "azurerm_storage_account" "function_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "messages" {
  name                  = "messages"
  storage_account_id    = azurerm_storage_account.function_storage.id
  container_access_type = "private"
}

resource "azurerm_service_plan" "function_plan" {
  name                = "asp-${var.function_app_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "main" {
  name                = var.function_app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.function_plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME            = "dotnet-isolated"
    ServiceBus__fullyQualifiedNamespace = "${azurerm_servicebus_namespace.main.name}.servicebus.windows.net"
    ServiceBusQueueName                 = azurerm_servicebus_queue.main.name
    StorageAccountName                  = azurerm_storage_account.function_storage.name
    StorageContainerName                = azurerm_storage_container.messages.name
  }
}

resource "azurerm_role_assignment" "function_servicebus_receiver" {
  scope                = azurerm_servicebus_namespace.main.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_linux_function_app.main.identity[0].principal_id
}

resource "azurerm_role_assignment" "function_storage_blob_contributor" {
  scope                = azurerm_storage_account.function_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.main.identity[0].principal_id
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "service_bus_namespace" {
  value = azurerm_servicebus_namespace.main.name
}

output "service_bus_queue" {
  value = azurerm_servicebus_queue.main.name
}

output "function_app_name" {
  value = azurerm_linux_function_app.main.name
}

output "storage_account_name" {
  value = azurerm_storage_account.function_storage.name
}