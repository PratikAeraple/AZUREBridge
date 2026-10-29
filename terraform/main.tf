locals {
  name_prefix = "azb-${var.environment}"
  tags = {
    project     = "AZUREBridge"
    environment = var.environment
    managed_by  = "Terraform"
  }
}

resource "azurerm_resource_group" "lab" {
  count    = var.enable_deployment ? 1 : 0
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "hub" {
  count               = var.enable_deployment ? 1 : 0
  name                = "${local.name_prefix}-vnet"
  address_space       = [var.address_space]
  location            = azurerm_resource_group.lab[0].location
  resource_group_name = azurerm_resource_group.lab[0].name
  tags                = local.tags
}

resource "azurerm_subnet" "workload" {
  count                = var.enable_deployment ? 1 : 0
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.lab[0].name
  virtual_network_name = azurerm_virtual_network.hub[0].name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 10)]
}

resource "azurerm_subnet" "management" {
  count                = var.enable_deployment ? 1 : 0
  name                 = "management"
  resource_group_name  = azurerm_resource_group.lab[0].name
  virtual_network_name = azurerm_virtual_network.hub[0].name
  address_prefixes     = [cidrsubnet(var.address_space, 8, 20)]
}

resource "azurerm_network_security_group" "workload" {
  count               = var.enable_deployment ? 1 : 0
  name                = "${local.name_prefix}-workload-nsg"
  location            = azurerm_resource_group.lab[0].location
  resource_group_name = azurerm_resource_group.lab[0].name
  tags                = local.tags

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "management" {
  count               = var.enable_deployment ? 1 : 0
  name                = "${local.name_prefix}-management-nsg"
  location            = azurerm_resource_group.lab[0].location
  resource_group_name = azurerm_resource_group.lab[0].name
  tags                = local.tags

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  count                     = var.enable_deployment ? 1 : 0
  subnet_id                 = azurerm_subnet.workload[0].id
  network_security_group_id = azurerm_network_security_group.workload[0].id
}

resource "azurerm_subnet_network_security_group_association" "management" {
  count                     = var.enable_deployment ? 1 : 0
  subnet_id                 = azurerm_subnet.management[0].id
  network_security_group_id = azurerm_network_security_group.management[0].id
}

resource "azurerm_user_assigned_identity" "workload" {
  count               = var.enable_deployment ? 1 : 0
  name                = "${local.name_prefix}-identity"
  location            = azurerm_resource_group.lab[0].location
  resource_group_name = azurerm_resource_group.lab[0].name
  tags                = local.tags
}

resource "azurerm_log_analytics_workspace" "lab" {
  count               = var.enable_deployment && var.enable_log_analytics ? 1 : 0
  name                = "${local.name_prefix}-logs"
  location            = azurerm_resource_group.lab[0].location
  resource_group_name = azurerm_resource_group.lab[0].name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_network_interface" "linux" {
  count               = var.enable_deployment && var.enable_linux_vm ? 1 : 0
  name                = "${local.name_prefix}-linux-nic"
  location            = azurerm_resource_group.lab[0].location
  resource_group_name = azurerm_resource_group.lab[0].name
  tags                = local.tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.workload[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linux" {
  count                           = var.enable_deployment && var.enable_linux_vm ? 1 : 0
  name                            = "${local.name_prefix}-linux"
  resource_group_name             = azurerm_resource_group.lab[0].name
  location                        = azurerm_resource_group.lab[0].location
  size                            = var.vm_size
  admin_username                  = "laboperator"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.linux[0].id]
  tags                            = local.tags

  admin_ssh_key {
    username   = "laboperator"
    public_key = var.ssh_public_key
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.workload[0].id]
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = var.linux_image_version
  }
}
