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

# Cognitive Services Account for OpenAI
resource "azurerm_cognitive_account" "openai" {
  name                = "${var.ai_foundry_name}-openai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"

  # Disable public network access for private endpoint usage
  public_network_access_enabled = false

  tags = var.tags
}

# OpenAI Model Deployment - GPT-5-Codex
resource "azurerm_cognitive_deployment" "gpt5_codex" {
  name                 = var.deployment_model_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

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

# Private Endpoint for OpenAI
resource "azurerm_private_endpoint" "openai_pe" {
  name                = "${var.ai_foundry_name}-openai-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.ai_foundry_name}-openai-psc"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name = "openai-dns-zone-group"
      private_dns_zone_ids = [
        for k, v in var.private_dns_zone_ids : v if can(regex("openai|cognitiveservices", k))
      ]
    }
  }

  tags = var.tags
}

# AI Foundry Hub (Azure Machine Learning Workspace)
resource "azapi_resource" "ai_hub" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01"
  name      = var.ai_foundry_name
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      description         = "AI Foundry Hub with Private Endpoints"
      friendlyName        = var.ai_foundry_name
      storageAccount      = azurerm_storage_account.ai_storage.id
      keyVault            = azurerm_key_vault.ai_keyvault.id
      applicationInsights = azurerm_application_insights.ai_insights.id
      containerRegistry   = azurerm_container_registry.ai_acr.id
      publicNetworkAccess = "Disabled"

      # Hub-specific properties
      hubResourceId = null
      kind          = "Hub"
    }
    kind = "Hub"
  })

  tags = var.tags

  depends_on = [
    azurerm_storage_account.ai_storage,
    azurerm_key_vault.ai_keyvault,
    azurerm_application_insights.ai_insights,
    azurerm_container_registry.ai_acr
  ]
}

# Private Endpoint for AI Hub
resource "azurerm_private_endpoint" "ai_hub_pe" {
  name                = "${var.ai_foundry_name}-hub-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.ai_foundry_name}-hub-psc"
    private_connection_resource_id = azapi_resource.ai_hub.id
    is_manual_connection           = false
    subresource_names              = ["amlworkspace"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name = "aihub-dns-zone-group"
      private_dns_zone_ids = [
        for k, v in var.private_dns_zone_ids : v if can(regex("azureml|ml", k))
      ]
    }
  }

  tags = var.tags
}

# AI Foundry Project
resource "azapi_resource" "ai_project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01"
  name      = var.ai_project_name
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      description         = "AI Foundry Project with GPT-5-Codex deployment"
      friendlyName        = var.ai_project_name
      hubResourceId       = azapi_resource.ai_hub.id
      publicNetworkAccess = "Disabled"
      kind                = "Project"
    }
    kind = "Project"
  })

  tags = var.tags

  depends_on = [
    azapi_resource.ai_hub,
    azurerm_private_endpoint.ai_hub_pe
  ]
}

# Connection from AI Project to OpenAI service
# Note: Using AAD (Managed Identity) authentication to avoid storing secrets in Terraform state
resource "azapi_resource" "openai_connection" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-04-01"
  name      = "openai-connection"
  parent_id = azapi_resource.ai_project.id

  body = jsonencode({
    properties = {
      category      = "AzureOpenAI"
      target        = azurerm_cognitive_account.openai.endpoint
      authType      = "AAD"
      isSharedToAll = true
      metadata = {
        ApiVersion = "2024-02-01"
        ResourceId = azurerm_cognitive_account.openai.id
      }
    }
  })

  depends_on = [
    azurerm_cognitive_deployment.gpt5_codex,
    azurerm_private_endpoint.openai_pe,
    azurerm_role_assignment.ai_project_openai_user
  ]
}

# Role assignment: Grant AI Project managed identity access to OpenAI
resource "azurerm_role_assignment" "ai_project_openai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = jsondecode(azapi_resource.ai_project.output).identity.principalId

  depends_on = [
    azapi_resource.ai_project
  ]
}
