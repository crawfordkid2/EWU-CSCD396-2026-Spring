variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-assignment3-crawford"
}

variable "location" {
  description = "Azure region"
  type        = string
  default = "westus3"
}

variable "environment_name" {
  description = "Name of the Container Apps Environment"
  type        = string
  default     = "env-assignment3-crawford"
}

variable "container_app_name" {
  description = "Name of the Container App"
  type        = string
  default     = "ca-assignment3-crawford"
}

variable "container_image_name" {
  description = "Full container image name passed from GitHub Actions"
  type        = string
}

variable "service_bus_namespace_name" {
  description = "Service Bus namespace name"
  type        = string
  default     = "sb-assignment3-crawford"
}

variable "service_bus_queue_name" {
  description = "Service Bus queue name"
  type        = string
  default     = "messages"
}

variable "storage_account_name" {
  description = "Storage account name for function output"
  type        = string
  default     = "stassignment3crawford"
}

variable "function_app_name" {
  description = "Function App name"
  type        = string
  default     = "func-assignment3-crawford"
}

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
  default     = "crawfordacr2026"
}
