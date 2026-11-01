resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "private"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  # checkov:skip=CKV_AZURE_50:Azure Monitor Agent is deliberately installed for guest logs; extension deployment requires privileged Azure access.
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_D2s_v5"
  admin_username                  = "azureadmin"
  network_interface_ids           = [azurerm_network_interface.this.id]
  disable_password_authentication = true
  encryption_at_host_enabled      = true
  secure_boot_enabled             = true
  vtpm_enabled                    = true
  patch_mode                      = "AutomaticByPlatform"
  patch_assessment_mode           = "AutomaticByPlatform"
  provision_vm_agent              = true
  allow_extension_operations      = true
  custom_data                     = base64encode(file("${path.module}/cloud-init.yaml"))
  tags                            = var.tags

  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "osdisk-${var.name}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Empty block selects Azure-managed boot diagnostics storage.
  boot_diagnostics {}
}

resource "azurerm_virtual_machine_extension" "monitor" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = var.tags
}

resource "azurerm_monitor_data_collection_rule" "this" {
  name                = "dcr-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"
  tags                = var.tags

  destinations {
    log_analytics {
      name                  = "central"
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  data_sources {
    syslog {
      name           = "security-and-system"
      facility_names = ["auth", "authpriv", "daemon", "syslog"]
      log_levels     = ["Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
      streams        = ["Microsoft-Syslog"]
    }
    performance_counter {
      name                          = "host-performance"
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["Processor(*)\\% Processor Time", "Memory(*)\\Available MBytes"]
      streams                       = ["Microsoft-Perf"]
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog", "Microsoft-Perf"]
    destinations = ["central"]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "this" {
  name                    = "dcra-${var.name}"
  target_resource_id      = azurerm_linux_virtual_machine.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_linux_virtual_machine.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}
