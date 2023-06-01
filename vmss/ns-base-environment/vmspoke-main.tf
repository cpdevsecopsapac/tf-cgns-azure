# Accept the agreement for the mgmt-byol for vmspoke image
resource "azurerm_marketplace_agreement" "vmspoke-agreement" {
  count = var.vmspoke-sku-enabled ? 0 : 1
  publisher = var.vmspoke-publisher
  offer = var.vmspoke-offer
  plan = var.vmspoke-sku
}

# VM-Spoke resource group
resource "azurerm_resource_group" "rg-vmspoke" {
    count = var.deploy-vmspoke ? length(var.num-spoke) : 0
    name = "rg-${var.vmspoke-name}-${count.index}"
    location = var.location
}

# VM-Spoke Create Public IP
resource "azurerm_public_ip" "pub-vmspoke" {
    count = var.deploy-vmspoke ? length(var.num-spoke) : 0
    name = "pub-${var.vmspoke-name}-${count.index}"
    location = var.location
    resource_group_name = "rg-${var.vmspoke-name}-${count.index}"
    allocation_method = "Static"  // Public IP Standard SKUs require allocation_method to be set to Static.
    domain_name_label = "pub-${var.vmspoke-name}-${count.index}-${var.mgmt-dns-suffix}"
    sku               = "Standard"  // default is Basic
    depends_on = [azurerm_resource_group.rg-vmspoke]
}

# VM-Spoke Network interface
resource "azurerm_network_interface" "nic-vmspoke" {
    count = var.deploy-vmspoke ? length(var.num-spoke) : 0
    name = "${var.vmspoke-name}-${count.index}-eth0"
    location = var.location
    resource_group_name = "rg-${var.vmspoke-name}-${count.index}"
    enable_ip_forwarding = "false"
    
	ip_configuration {
        name = "${var.vmspoke-name}-${count.index}-eth0-config"
        subnet_id = azurerm_subnet.net-spoke-web[count.index].id
        private_ip_address_allocation = "Dynamic"
        primary = true
		public_ip_address_id = azurerm_public_ip.pub-vmspoke[count.index].id
    }
    depends_on = [azurerm_public_ip.pub-vmspoke,azurerm_subnet.net-spoke-web]
}

# Create NSG for the vmspoke
resource "azurerm_network_security_group" "nsg-vmspoke" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0
  name = "nsg-${var.vmspoke-name}-${count.index}"
  location = var.location
  resource_group_name = "rg-${var.vmspoke-name}-${count.index}"
  depends_on = [azurerm_resource_group.rg-vmspoke]
}

# Create the NSG rules for the vmspoke
resource "azurerm_network_security_rule" "nsg-vmspoke-rl-ssh" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0   
  priority = 100
  name = "ssh-access"

  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix  = var.my-pub-ip
  destination_address_prefix = "*"
  resource_group_name  = "rg-${var.vmspoke-name}-${count.index}"
  network_security_group_name = "nsg-${var.vmspoke-name}-${count.index}"
  depends_on = [azurerm_network_security_group.nsg-vmspoke]
}
resource "azurerm_network_security_rule" "nsg-vmspoke-rl-http-s" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0   
  priority = 110
  name = "http-s-access"

  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_ranges = ["80","443"]
  source_address_prefix  = "*"
  destination_address_prefix = "*"
  resource_group_name  = "rg-${var.vmspoke-name}-${count.index}"
  network_security_group_name = "nsg-${var.vmspoke-name}-${count.index}"
  depends_on = [azurerm_network_security_group.nsg-vmspoke]
}

resource "azurerm_network_interface_security_group_association" "nsg-assoc-nic-vmspoke" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0
  network_interface_id      = azurerm_network_interface.nic-vmspoke[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-vmspoke[count.index].id
  depends_on = [azurerm_network_interface.nic-vmspoke,azurerm_network_security_group.nsg-vmspoke]
}

# VM-Spoke Virtual Machine - Bitnami
#data "template_file" "init_scripts" {
#  count = var.deploy-vmspoke ? length(var.num-spoke) : 0
#  template = "${file("scripts/install-${count.index}.sh")}"
#}

resource "azurerm_virtual_machine" "vm-spoke" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0
  name = "${var.vmspoke-name}-${count.index}"
  location = var.location
  resource_group_name = "rg-${var.vmspoke-name}-${count.index}"
  network_interface_ids = [azurerm_network_interface.nic-vmspoke[count.index].id]
  vm_size = "Standard_A1_v2"
  plan {
      publisher = var.vmspoke-publisher
      product = var.vmspoke-offer
      name = var.vmspoke-sku
  }
  storage_image_reference {
      publisher = var.vmspoke-publisher
      offer     = var.vmspoke-offer
      sku       = var.vmspoke-sku
      version   = "latest"
  }
  storage_os_disk {
      name              = "disk-${var.vmspoke-name}-${count.index}"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.vmspoke-name}-${count.index}"
    admin_username = var.vmspoke-usr
    admin_password = var.vmspoke-pwd
#    custom_data    = "${data.template_file.init_scripts[count.index].rendered}"
    custom_data    = file("scripts/install-${count.index}.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  depends_on = [azurerm_marketplace_agreement.vmspoke-agreement,azurerm_resource_group.rg-vmspoke,
              azurerm_network_interface.nic-vmspoke]
}


# add a Win10 VM and NSG to 10.0.5.0/24 azurerm_subnet.net-spoke-db[1] subnet
resource "azurerm_public_ip" "pub-vmspoke-win" {
  name = "pub-${var.vmspoke-name}-win"
  location = var.location
  resource_group_name = "rg-${var.vmspoke-name}-1"
  allocation_method = "Static"  // Public IP Standard SKUs require allocation_method to be set to Static.
  domain_name_label = "pub-${var.vmspoke-name}-win-${var.mgmt-dns-suffix}"
  sku               = "Standard"  // default is Basic
  depends_on = [azurerm_resource_group.rg-vmspoke]
}
resource "azurerm_network_interface" "nic-vmspoke-win" {
  name = "${var.vmspoke-name}-win-eth0"
  location = var.location
  resource_group_name = "rg-${var.vmspoke-name}-1"
  enable_ip_forwarding = "false"
  
	ip_configuration {
    name = "${var.vmspoke-name}-win-eth0-config"
    subnet_id = azurerm_subnet.net-spoke-db[1].id
    private_ip_address_allocation = "Dynamic"
    primary = true
		public_ip_address_id = azurerm_public_ip.pub-vmspoke-win.id
  }
  depends_on = [azurerm_public_ip.pub-vmspoke-win,azurerm_subnet.net-spoke-db]
}
resource "azurerm_network_security_group" "nsg-vmspoke-win" {
  name = "nsg-${var.vmspoke-name}-win"
  location = var.location
  resource_group_name = "rg-${var.vmspoke-name}-1"
  depends_on = [azurerm_resource_group.rg-vmspoke]
#  security_rule {
#    name                       = "AllowICMPInbound"
#    priority                   = 100
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Icmp"
#    source_port_range          = "*"
#    destination_port_range     = "*"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
}
resource "azurerm_network_security_rule" "nsg-vmspoke-rl-win" {
  priority = 110
  name = "win-access"

  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_ranges = ["80","443","3389"]
  source_address_prefix  = "*"
  destination_address_prefix = "*"
  resource_group_name  = "rg-${var.vmspoke-name}-1"
  network_security_group_name = "nsg-${var.vmspoke-name}-win"
  depends_on = [azurerm_network_security_group.nsg-vmspoke-win]
}
resource "azurerm_network_security_rule" "nsg-vmspoke-rl-win-icmp" {
  priority = 120
  name = "win-icmp"

  direction = "Inbound"
  access = "Allow"
  protocol = "Icmp"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix  = "*"
  destination_address_prefix = "*"
  resource_group_name  = "rg-${var.vmspoke-name}-1"
  network_security_group_name = "nsg-${var.vmspoke-name}-win"
  depends_on = [azurerm_network_security_group.nsg-vmspoke-win]
}
resource "azurerm_network_interface_security_group_association" "nsg-assoc-nic-vmspoke-win" {
  network_interface_id      = azurerm_network_interface.nic-vmspoke-win.id
  network_security_group_id = azurerm_network_security_group.nsg-vmspoke-win.id
  depends_on = [azurerm_network_interface.nic-vmspoke-win,azurerm_network_security_group.nsg-vmspoke-win]
}

resource "azurerm_windows_virtual_machine" "this" {
  name                  = "${var.vmspoke-name}-win10"
  location              = var.location
  resource_group_name   = "rg-${var.vmspoke-name}-1"
  size                  = "Standard_D2_v2"
  computer_name         = "test-win10"
  admin_username        = var.vmspoke-usr
  admin_password        = var.vmspoke-pwd
  network_interface_ids = [
    azurerm_network_interface.nic-vmspoke-win.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-21h2-pro"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    Internet_Access = "yes"
  }
}


# 仮想マシンの機能拡張（アプリのインストール）
#resource "azurerm_virtual_machine_extension" "git" {
#  name                  = azurerm_windows_virtual_machine.this.name
#  virtual_machine_id    = azurerm_windows_virtual_machine.this.id
#  publisher             = "Microsoft.Compute"
#  type                  = "CustomScriptExtension"
#  type_handler_version  = "1.9"
#
#  # VMにダウンロードするファイル(準備したファイルのフルパス)と実行するPowershellを設定
#  settings = <<SETTINGS
#  {
#      "fileUris": [
#          "https://iturutfstate.blob.core.windows.net/app/init_app.ps1",
#          "https://iturutfstate.blob.core.windows.net/app/azure-cli-2.33.1.msi",
#          "https://iturutfstate.blob.core.windows.net/app/Git-2.35.1.2-64-bit.exe",
#          "https://iturutfstate.blob.core.windows.net/app/VSCodeUserSetup-x64-1.64.2.exe"
#      ],
#      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File \"init_app.ps1\""
#  }
#  SETTINGS
#}



output "vmspoke-output-fqdn" {
  value = azurerm_public_ip.pub-vmspoke[*].fqdn
  depends_on = [azurerm_public_ip.pub-vmspoke]
}
output "vmspoke-output-ip-address" {
  value = azurerm_public_ip.pub-vmspoke[*].ip_address
  depends_on = [azurerm_public_ip.pub-vmspoke]
}
output "vmspoke-win-public-ip-address" {
  value = azurerm_public_ip.pub-vmspoke-win.ip_address
  depends_on = [azurerm_public_ip.pub-vmspoke-win]
}
output "vmspoke-win-private-ip-address" {
  value = azurerm_network_interface.nic-vmspoke-win.private_ip_address
  depends_on = [azurerm_public_ip.pub-vmspoke-win]
}
output "vmspoke-win-output-fqdn" {
  value = azurerm_public_ip.pub-vmspoke-win.fqdn
  depends_on = [azurerm_public_ip.pub-vmspoke-win]
}
