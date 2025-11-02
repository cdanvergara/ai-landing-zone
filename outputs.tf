output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "ai_foundry_id" {
  description = "ID of the AI Foundry resource"
  value       = azurerm_cognitive_account.ai_foundry.id
}

output "ai_foundry_name" {
  description = "Name of the AI Foundry resource"
  value       = azurerm_cognitive_account.ai_foundry.name
}

output "ai_foundry_endpoint" {
  description = "Endpoint URL for the AI Foundry service"
  value       = azurerm_cognitive_account.ai_foundry.endpoint
}

output "ai_project_id" {
  description = "ID of the AI Foundry Project"
  value       = azapi_resource.ai_project.id
}

output "ai_project_name" {
  description = "Name of the AI Foundry Project"
  value       = azapi_resource.ai_project.name
}

output "gpt5_codex_deployment_name" {
  description = "Name of the GPT-5-Codex deployment"
  value       = azurerm_cognitive_deployment.gpt5_codex.name
}

output "ai_foundry_private_endpoint_id" {
  description = "ID of the AI Foundry private endpoint"
  value       = azurerm_private_endpoint.ai_foundry_pe.id
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
