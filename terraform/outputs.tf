output "resource_group_name" {
  description = "Resource group containing the AZUREBridge lab resources."
  value       = var.enable_deployment ? azurerm_resource_group.lab[0].name : null
}

output "vnet_id" {
  description = "Private hub VNet resource ID."
  value       = var.enable_deployment ? azurerm_virtual_network.hub[0].id : null
}

output "workload_subnet_id" {
  description = "Workload subnet resource ID."
  value       = var.enable_deployment ? azurerm_subnet.workload[0].id : null
}

output "linux_private_ip" {
  description = "Private IP of the optional Linux VM; null when VM creation is disabled."
  value       = var.enable_deployment && var.enable_linux_vm ? azurerm_network_interface.linux[0].private_ip_address : null
}
