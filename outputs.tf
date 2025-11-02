output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "ai_hub_id" {
  description = "ID of the AI Foundry Hub"
  value       = azapi_resource.ai_hub.id
}

output "ai_hub_name" {
  description = "Name of the AI Foundry Hub"
  value       = azapi_resource.ai_hub.name
}

output "ai_project_id" {
  description = "ID of the AI Foundry Project"
  value       = azapi_resource.ai_project.id
}

output "ai_project_name" {
  description = "Name of the AI Foundry Project"
  value       = azapi_resource.ai_project.name
}

output "openai_account_id" {
  description = "ID of the OpenAI Cognitive Services Account"
  value       = azurerm_cognitive_account.openai.id
}

output "openai_account_name" {
  description = "Name of the OpenAI Cognitive Services Account"
  value       = azurerm_cognitive_account.openai.name
}

output "openai_endpoint" {
  description = "Endpoint URL for the OpenAI service"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "gpt5_codex_deployment_name" {
  description = "Name of the GPT-5-Codex deployment"
  value       = azurerm_cognitive_deployment.gpt5_codex.name
}

output "openai_private_endpoint_id" {
  description = "ID of the OpenAI private endpoint"
  value       = azurerm_private_endpoint.openai_pe.id
}

output "ai_hub_private_endpoint_id" {
  description = "ID of the AI Hub private endpoint"
  value       = azurerm_private_endpoint.ai_hub_pe.id
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.ai_storage.name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.ai_keyvault.name
}

output "container_registry_name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.ai_acr.name
}

output "application_insights_name" {
  description = "Name of the Application Insights"
  value       = azurerm_application_insights.ai_insights.name
}
