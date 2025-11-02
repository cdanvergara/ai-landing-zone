# Data source to get current Azure subscription
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Storage Account for AI Foundry
resource "azurerm_storage_account" "ai_storage" {
  name = substr(
    lower(replace("${var.ai_foundry_name}st", "-", "")),
    0,
    24
  )
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable blob encryption
  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

# Key Vault for AI Foundry
resource "azurerm_key_vault" "ai_keyvault" {
  name = substr(
    lower(replace("${var.ai_foundry_name}-kv", "/[^a-z0-9-]/", "")),
    0,
    24
  )
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = var.tags
}

# Key Vault access policy for AI Foundry system identity
resource "azurerm_key_vault_access_policy" "ai_foundry_kv_policy" {
  key_vault_id = azurerm_key_vault.ai_keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_cognitive_account.ai_foundry.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update"
  ]

  depends_on = [
    azurerm_cognitive_account.ai_foundry
  ]
}

# Application Insights
resource "azurerm_application_insights" "ai_insights" {
  name                = "${var.ai_foundry_name}-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = var.tags
}

# Container Registry for AI Foundry
resource "azurerm_container_registry" "ai_acr" {
  name = substr(
    lower(replace("${var.ai_foundry_name}acr", "-", "")),
    0,
    50
  )
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true

  tags = var.tags
}

# AI Foundry Resource (replaces separate OpenAI service)
resource "azurerm_cognitive_account" "ai_foundry" {
  name                = var.ai_foundry_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "AIServices"
  sku_name            = "S0"

  # Enable custom subdomain for private endpoints
  custom_subdomain_name = lower(replace(var.ai_foundry_name, "-", ""))

  # Disable public network access for private endpoint usage
  public_network_access_enabled = false

  # Enable system assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# GPT-5-Codex Model Deployment in AI Foundry
resource "azurerm_cognitive_deployment" "gpt5_codex" {
  name                 = var.deployment_model_name
  cognitive_account_id = azurerm_cognitive_account.ai_foundry.id

  model {
    format  = "OpenAI"
    name    = "gpt-5-codex"
    version = var.deployment_model_version
  }

  sku {
    name     = var.deployment_sku_name
    capacity = var.deployment_capacity
  }
}

# Private Endpoint for AI Foundry
resource "azurerm_private_endpoint" "ai_foundry_pe" {
  name                = "${var.ai_foundry_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.ai_foundry_name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.ai_foundry.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name = "ai-foundry-dns-zone-group"
      private_dns_zone_ids = [
        for k, v in var.private_dns_zone_ids : v if can(regex("openai|cognitiveservices", k))
      ]
    }
  }

  tags = var.tags
}

# AI Foundry Project (new unified model)
resource "azapi_resource" "ai_project" {
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview"
  name      = var.ai_project_name
  parent_id = azurerm_cognitive_account.ai_foundry.id

  body = jsonencode({
    properties = {
      description  = "AI Foundry Project with GPT-5-Codex deployment"
      friendlyName = var.ai_project_name
    }
  })

  tags = var.tags

  depends_on = [
    azurerm_cognitive_account.ai_foundry,
    azurerm_private_endpoint.ai_foundry_pe
  ]
}

# Role assignment: Grant AI Foundry system identity access to dependent resources
resource "azurerm_role_assignment" "ai_foundry_storage_contributor" {
  scope                = azurerm_storage_account.ai_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_cognitive_account.ai_foundry.identity[0].principal_id

  depends_on = [
    azurerm_cognitive_account.ai_foundry
  ]
}

resource "azurerm_role_assignment" "ai_foundry_keyvault_user" {
  scope                = azurerm_key_vault.ai_keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_cognitive_account.ai_foundry.identity[0].principal_id

  depends_on = [
    azurerm_cognitive_account.ai_foundry
  ]
}
