# Official technical references

Version-sensitive references checked for this implementation on 2026-10-29:

- [HashiCorp Terraform releases](https://releases.hashicorp.com/terraform/) — CLI version 1.17.1 was the latest stable release observed; the project lock is validated with that binary.
- [AzureRM provider 5.10.0 documentation](https://registry.terraform.io/providers/hashicorp/azurerm/5.10.0/docs) — provider version locked to 5.10.0. The provider is the standard typed provider for Azure Resource Manager resources.
- [Microsoft Learn: Azure Terraform provider selection](https://learn.microsoft.com/en-us/azure/developer/terraform/provider-selection-azurerm-vs-azapi) — AzureRM is used here for standard resource types; AzAPI is not needed in this initial design.
- [Microsoft Learn: Terraform state in Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage) — state can contain sensitive values; use a protected backend and narrow access before any real deployment.
- [Microsoft Learn: Developer and admin access to Azure VMs](https://learn.microsoft.com/en-us/azure/networking/design-guide/developer-admin-access) — compare Bastion, P2S VPN and JIT access; this repository deploys none of them.
- [Microsoft Learn: Azure Bastion architecture](https://learn.microsoft.com/en-us/azure/bastion/design-architecture) — Bastion placement and connectivity require a deliberate management path.

The project does not claim that these references prove a real environment has been deployed. Re-check Azure pricing, VM image versions, regional quotas, product behavior and provider documentation immediately before any future deployment.
