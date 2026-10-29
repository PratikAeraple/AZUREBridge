# Azure operations design

## Identity and RBAC

The optional Linux workload receives a user-assigned managed identity. The initial configuration deliberately grants it no role: a workload identity without a concrete resource need should not receive subscription-wide access. In a real deployment, scope role assignments to the exact resource group or resource, select a built-in least-privilege role after reviewing its actions, and test access-denied as well as expected access. Human administrators use Entra ID groups and Azure RBAC; avoid standing Owner/Contributor access for routine work. No Entra tenant, RBAC role assignment or managed identity exists until the gated configuration is deliberately deployed.

## Network and administration

There is no public IP or SSH ingress in Terraform. The workload subnet NSG denies inbound Internet traffic; management access is a future separately designed path through a compatible S2S/P2S VPN or Azure Bastion. Bastion itself has dedicated subnet, NSG, public IP and hourly/data charges, so it is not enabled in this baseline. A proposed VPN must use non-overlapping ranges, reviewed routing, key-based/identity-based administration and connection logging. Avoid publishing RDP/SSH directly.

## Monitoring and alerting

The optional Log Analytics workspace is billable and off by default. Before enabling it, set a daily cap/retention appropriate to the current Azure product options, identify which diagnostic categories are required, and define alert ownership, severity, deduplication and recovery behavior. No alert history or monitoring coverage is claimed by this repository. Local Terraform validation does not prove that Azure Monitor ingestion or an alert works.

## Windows workload design

Windows Server/AD is not created by the current Terraform root. A future Windows workload requires an approved Windows image, licensing/cost review, private subnet, managed identity, boot diagnostics policy, update/backup plan, and controlled management through Bastion or VPN. Do not add a public RDP rule. DOMAINCORE contains the Windows identity/endpoint design artifacts; there is no deployed directory or Windows VM in this Azure project.

## Backup design

Azure Backup is a proposed future control, not an implemented resource. A reviewed design would use a Recovery Services vault with soft delete/immutability settings appropriate to current capabilities, policy-based VM protection, independent access controls, alerting, and periodic restore exercises into an isolated network. Retention and storage redundancy must be chosen against cost, legal requirements and recovery objectives. No Azure vault, backup job or restore has been created or tested.

BruteHost production backups remain **DEFERRED / NOT IMPLEMENTED** and are separate from this cloud architecture project.
