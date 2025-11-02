variable "resource_group_name" {
  description = "Name of the resource group where AI Foundry resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "ai_foundry_name" {
  description = "Name of the AI Foundry Hub"
  type        = string
}

variable "ai_project_name" {
  description = "Name of the AI Foundry Project"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for private endpoints (from existing VNet)"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Map of private DNS zone IDs for different services (e.g., cognitive_account, openai_account)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "deployment_model_name" {
  description = "Name of the deployment model"
  type        = string
  default     = "gpt-5-codex-deployment"
}

variable "deployment_model_version" {
  description = "Version of the GPT-5-Codex model"
  type        = string
  default     = "0125"
}

variable "deployment_sku_name" {
  description = "SKU name for the deployment"
  type        = string
  default     = "Standard"
}

variable "deployment_capacity" {
  description = "Capacity for the deployment (in thousands of tokens per minute)"
  type        = number
  default     = 10
}
