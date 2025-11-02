# AI Landing Zone - Azure AI Foundry with Private Endpoints

This Terraform template deploys the new Azure AI Foundry unified platform with a GPT-5-Codex deployment using private endpoints for secure, enterprise-grade AI infrastructure.

## Architecture Overview

This template creates:
- **Azure AI Foundry Resource**: Unified AI services platform (replaces separate OpenAI service)
- **Azure AI Foundry Project**: Project workspace for AI development (child resource)
- **GPT-5-Codex Model Deployment**: Latest GPT-5-Codex model optimized for coding tasks with multimodal capabilities
- **Private Endpoints**: For secure access to AI Foundry services
- **Supporting Services**: Storage Account, Key Vault, Container Registry, Application Insights

## Prerequisites

Before deploying this template, ensure you have:

1. **Azure Subscription** with sufficient permissions to create resources
2. **Existing VNet and Subnet** for private endpoints
3. **Private DNS Zones** (optional, but recommended):
   - `privatelink.openai.azure.com`
   - `privatelink.cognitiveservices.azure.com`
   - `privatelink.api.azureml.ms`
   - `privatelink.notebooks.azure.net`
4. **Terraform** >= 1.0 installed
5. **Azure CLI** authenticated (`az login`)

## Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/cdanvergara/ai-landing-zone.git
   cd ai-landing-zone
   ```

2. **Create your variables file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit `terraform.tfvars`** with your values:
   ```hcl
   resource_group_name = "rg-ai-foundry-prod"
   location            = "eastus"
   ai_foundry_name     = "aihub-prod"
   ai_project_name     = "aiproject-prod"
   subnet_id           = "/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>"
   ```

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Plan the deployment**:
   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Configuration

### Required Variables

- `resource_group_name`: Name of the resource group to create
- `ai_foundry_name`: Name for the AI Foundry Hub
- `ai_project_name`: Name for the AI Foundry Project
- `subnet_id`: Resource ID of the subnet for private endpoints

### Optional Variables

- `location`: Azure region (default: "eastus")
- `private_dns_zone_ids`: Map of private DNS zone IDs
- `deployment_model_name`: Name for the GPT-5-Codex deployment (default: "gpt-5-codex-deployment")
- `deployment_model_version`: Model version (default: "0125")
- `deployment_capacity`: Capacity in thousands of tokens per minute (default: 10)
- `tags`: Resource tags

## Private DNS Zones

If you have Private DNS Zones configured in a hub VNet, provide them in the `private_dns_zone_ids` variable:

```hcl
private_dns_zone_ids = {
  cognitiveservices   = "/subscriptions/.../privatelink.cognitiveservices.azure.com"
  openai              = "/subscriptions/.../privatelink.openai.azure.com"
}
```

## Outputs

After successful deployment, the following outputs are available:

- `ai_foundry_id`, `ai_foundry_name`, `ai_foundry_endpoint`: AI Foundry resource identifiers
- `ai_project_id` and `ai_project_name`: AI Foundry Project identifiers
- `gpt5_codex_deployment_name`: Name of the deployed GPT-5-Codex model
- `ai_foundry_private_endpoint_id`: Private endpoint ID

## Security Features

- **Public network access disabled** on AI Foundry resource
- **Private endpoints** for all network connectivity
- **System-assigned managed identities** for secure authentication
- **Key Vault** for secrets management
- **Blob versioning** enabled on Storage Account

## Accessing the Deployment

After deployment, access your AI Foundry resources through:

1. **Azure Portal**: Navigate to the AI Foundry resource
2. **Azure AI Foundry portal**: https://ai.azure.com
3. **Private connectivity**: Ensure you're connected to the VNet via VPN or ExpressRoute

## Migration from Hub-based Model

This template uses the new unified AI Foundry project model. If you're migrating from the previous hub-based model:
- The new model simplifies resource management with a single AI Foundry resource
- Projects are now child resources of the main AI Foundry resource
- Model deployments are created directly in the AI Foundry resource
- Better integration with the latest AI capabilities and agent services

## Clean Up

To destroy all resources created by this template:

```bash
terraform destroy
```

## License

See [LICENSE](LICENSE) file for details.

## Support

For issues or questions, please open an issue in the GitHub repository.
