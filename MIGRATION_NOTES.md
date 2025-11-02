# Migration to New AI Foundry Project Model

This document outlines the changes made to migrate from the old hub-based AI Foundry model to the new unified AI Foundry project model.

## Key Changes

### 1. Architecture Simplification
- **Before**: Separate OpenAI Cognitive Services + AI Hub + AI Project
- **After**: Single AI Foundry resource with child project

### 2. Resource Changes

#### Removed Resources:
- `azurerm_cognitive_account.openai` (separate OpenAI service)
- `azapi_resource.ai_hub` (ML Services workspace hub)
- `azurerm_private_endpoint.ai_hub_pe` (hub private endpoint)
- `azapi_resource.openai_connection` (connection resource)

#### New/Updated Resources:
- `azurerm_cognitive_account.ai_foundry` (unified AI services)
- `azurerm_cognitive_deployment.gpt4o` (GPT-4o instead of GPT-5-Codex)
- `azapi_resource.ai_project` (child project resource)
- `azurerm_private_endpoint.ai_foundry_pe` (unified private endpoint)

### 3. Model Updates
- **Model**: Changed from hypothetical "GPT-5-Codex" to real "GPT-4o"
- **Version**: Updated to "2024-11-20" (latest GPT-4o version)
- **Deployment**: Now created directly in AI Foundry resource

### 4. Variable Changes
- Updated `ai_foundry_name` validation for AI Services naming requirements
- Updated default values for GPT-4o model deployment
- Maintained backward compatibility for most variables

### 5. Output Changes
- Consolidated outputs around single AI Foundry resource
- Removed separate OpenAI and Hub outputs
- Added unified AI Foundry endpoint output

### 6. Security Improvements
- System-assigned managed identity on AI Foundry resource
- Proper Key Vault access policies
- Storage account role assignments
- Maintained private endpoint security

## Benefits of New Model

1. **Simplified Management**: Single resource instead of multiple interconnected services
2. **Better Integration**: Native support for latest AI capabilities and agent services
3. **Unified Experience**: Consistent APIs and SDKs across all AI services
4. **Cost Optimization**: Reduced resource overhead and management complexity
5. **Future-Proof**: Built for new generative AI and model-centric features

## Migration Path

For existing deployments using the old model:
1. **New Deployments**: Use this updated template directly
2. **Existing Deployments**: Plan for recreation as resource types have changed
3. **Data Migration**: Export/import data and models as needed
4. **DNS Updates**: Update private DNS zone configurations

## Private DNS Zones

Updated private DNS zone requirements:
- `privatelink.cognitiveservices.azure.com` (primary)
- `privatelink.openai.azure.com` (for OpenAI endpoints)

Removed requirements:
- `privatelink.api.azureml.ms`
- `privatelink.notebooks.azure.net`

## API Versions Used

- AI Foundry Resource: `Microsoft.CognitiveServices/accounts` (AzureRM provider)
- AI Foundry Project: `Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview`
- Model Deployment: `Microsoft.CognitiveServices/accounts/deployments` (AzureRM provider)