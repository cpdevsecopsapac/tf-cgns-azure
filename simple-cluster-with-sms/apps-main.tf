# Accept the agreement for vmspoke image
resource "azurerm_marketplace_agreement" "vmspoke-agreement" {
  count = var.vmspoke-sku-enabled ? 0 : 1
  publisher = var.vmspoke-publisher
  offer = var.vmspoke-offer
  plan = var.vmspoke-sku
}

# Create apps resource group
resource "azurerm_resource_group" "rg-ckpapps" {
  name = "cl-${var.apps-name}"
  location = var.location
}


#//********************** Security Groups **************************//
## Create Application Security Group
#resource "azurerm_application_security_group" "app_web_asg" {
#  name                = "my-appweb-asg"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#
#  tags = {
#    type = "appweb"
#  }
#}
#
## Create Network Security Group and rule
#resource "azurerm_network_security_group" "my-db-nsg" {
#  name                = "mydbnsg"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#
#  security_rule {
#    name                       = "AllowDBInbound"
#    priority                   = 100
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_ranges    = ["5432","3306","1433"]
#    source_application_security_group_ids = ["${azurerm_application_security_group.app_web_asg.id}"]
##    source_address_prefixes    = ["10.0.3.0/24","10.0.4.0/24"]
#    destination_address_prefix = "*"
#    description                = "Allow DB inbound connections"
#  }
#
#  security_rule {
#    name                       = "DenyAny"
#    priority                   = 101
#    direction                  = "Inbound"
#    access                     = "Deny"
#    protocol                   = "*"
#    source_port_range          = "*"
#    destination_port_range     = "*"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#    description                = "Deny any inbound"
#  }
#
#  security_rule {
#    name                       = "BlockOutbound"
#    priority                   = 1051
#    direction                  = "Outbound"
#    access                     = "Deny"
#    protocol                   = "*"
#    source_port_range          = "*"
#    destination_port_range     = "*"
#    source_address_prefix      = "*"
#    destination_address_prefix = "Internet"
#    description                = "Deny outbound connections"
#  }
#
##  tags = merge(local.shared_tags)
#}
#
#resource "azurerm_network_security_group" "my-app-web-nsg" {
#  name                = "myappwebnsg"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#
#  security_rule {
#    name                       = "AllowAppWebInbound"
#    priority                   = 100
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "Tcp"
#    source_port_range          = "*"
#    destination_port_ranges    = ["8081","8083"]
#    source_address_prefix      = "${azurerm_lb.backend-lb.private_ip_address}"
#    destination_address_prefix = "*"
#    description                = "Allow App and Web inbound connections"
#  }
#
#  security_rule {
#    name                       = "DenyAny"
#    priority                   = 101
#    direction                  = "Inbound"
#    access                     = "Deny"
#    protocol                   = "*"
#    source_port_range          = "*"
#    destination_port_range     = "*"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#    description                = "Deny any inbound"
#  }
#}
#
#resource "azurerm_subnet_network_security_group_association" "security_group_app_association" {
#  depends_on = [module.vnet, azurerm_subnet.app_subnet]
#  subnet_id = azurerm_subnet.app_subnet.id
#  network_security_group_id = azurerm_network_security_group.my-app-web-nsg.id
#}
#
#resource "azurerm_subnet_network_security_group_association" "security_group_web_association" {
#  depends_on = [module.vnet, azurerm_subnet.web_subnet]
#  subnet_id = azurerm_subnet.web_subnet.id
#  network_security_group_id = azurerm_network_security_group.my-app-web-nsg.id
#}
#
#
## Connect the security group to the network interface
#resource "azurerm_network_interface_application_security_group_association" "app_example" {
#  network_interface_id          = azurerm_network_interface.app_nic.id
#  application_security_group_id = azurerm_application_security_group.app_web_asg.id
#}
#resource "azurerm_network_interface_application_security_group_association" "web_example" {
#  network_interface_id          = azurerm_network_interface.web_nic.id
#  application_security_group_id = azurerm_application_security_group.app_web_asg.id
#}
#resource "azurerm_network_interface_security_group_association" "db_example" {
#  network_interface_id      = azurerm_network_interface.db_nic.id
#  network_security_group_id = azurerm_network_security_group.my-db-nsg.id
#}


# Create network interface
resource "azurerm_network_interface" "web_nic" {
  name                = "webNIC"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-ckpapps.name

  ip_configuration {
    name                          = "webNicConfiguration"
    subnet_id                     = azurerm_subnet.net-web.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg-ckpapps.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_virtual_machine" "web_vm" {
  count                 = 1
  name                  = "webvm-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-ckpapps.name
  network_interface_ids = [azurerm_network_interface.web_nic.id]
  vm_size                  = "Standard_DS1_v2"

  plan {
      publisher = var.vmspoke-publisher
      product   = var.vmspoke-offer
      name      = var.vmspoke-sku
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
    #custom_data    = file("scripts/install-${count.index}.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  depends_on = [azurerm_marketplace_agreement.vmspoke-agreement,azurerm_resource_group.rg-ckpapps,
              azurerm_network_interface.web_nic]
}
