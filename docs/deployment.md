# Deployment and cost boundary

## What the configuration creates

The root configuration describes a resource group, hub VNet, workload and management subnets, a deny-inbound workload NSG, a user-assigned identity, and optional Log Analytics and Linux VM resources. It intentionally contains no public IP address, public SSH rule, VPN gateway, Bastion, storage account, backup vault, or Windows VM. Those require a separate architecture and cost review before implementation.

Every resource is gated behind `enable_deployment`, which defaults to `false`. Enabling it also requires the exact acknowledgement variable `deployment_acknowledgement=AZURE_COST_REVIEWED_AND_APPROVED`. This is a guardrail, not owner approval: do not enable it until a subscription, region, estimates, quotas, security controls, and explicit deployment authorization have been reviewed.

The Linux VM and Log Analytics workspace are separately disabled by default. A VM uses private networking only and SSH public-key authentication. When the VM is enabled, Terraform requires an explicit image version and public key rather than floating to an unreviewed image. The AzureRM provider obtains authentication through the standard Azure CLI / workload identity environment; no credential is embedded here.

## Local validation

Use Terraform CLI 1.17.1 and AzureRM provider 5.10.x with the committed provider lock file. `terraform fmt -check -recursive` and `terraform validate` do not create Azure resources. `terraform init` downloads provider binaries; treat them as generated dependencies and do not commit `.terraform/`.

```sh
cd terraform
terraform fmt -check -recursive
terraform init -backend=false -input=false
terraform validate
```

`terraform plan` may require a subscription ID even with all resource counts at zero. Do not authenticate to or select a paid subscription solely to make a demo look deployed. No `apply` has been run for this project.

## State protection

Terraform state can contain resource identifiers and sensitive values. Use an approved encrypted remote backend with narrowly scoped access and state locking before any real deployment. Do not commit state, plan files, provider credentials, CLI caches, or backend configuration containing secrets. The repository intentionally has no real subscription ID or backend credentials.

## Proposed hybrid options

The reference design separates a BruteHost/on-premises lab from Azure address space. An IPsec site-to-site VPN is the normal always-on option when a compatible gateway and stable network edge exist. Point-to-site VPN or Azure Bastion are operator access alternatives; neither is currently deployed by this repository. Private endpoints should be added only alongside private DNS integration and a demonstrated service need. NSGs are subnet controls, not a substitute for host firewalls or identity authorization.

## Cost and cleanup

Even a small VM, managed disk, Log Analytics ingestion, VPN gateway, Bastion, public IP, or backup vault can incur charges. Estimate by region and duration before enabling. If a future lab is approved, record the plan, resources, teardown, and actual billing evidence. This project does not claim Azure resources or costs exist.
