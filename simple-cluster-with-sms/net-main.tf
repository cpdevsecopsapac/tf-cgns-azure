# Configuration of Terraform with Azure environment variables
terraform {
  required_version = ">= 0.14.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.92.0"
    }
    random = {
      version = "~> 2.2.1"
    }
  }
}

provider "azurerm" {
  features { }
#  client_id = var.azure-client-id
#  client_secret = var.azure-client-secret
#  subscription_id = var.azure-subscription
#  tenant_id = var.azure-tenant
}

# Creation of the Southbound Hub
resource "azurerm_resource_group" "rg-vnet-south" {
  name = "cl-v${var.net-south}"
  location = var.location
}
#resource "azurerm_network_security_group" "nsg-vnet-south" {
#  name = "nsg-v${var.net-south}"
#  location = azurerm_resource_group.rg-vnet-south.location
#  resource_group_name = azurerm_resource_group.rg-vnet-south.name
#  depends_on = [azurerm_resource_group.rg-vnet-south]
#}
resource "azurerm_virtual_network" "vnet-south" {
  name = "v${var.net-south}"
  address_space = ["172.20.0.0/22"]
  location = azurerm_resource_group.rg-vnet-south.location
  resource_group_name = azurerm_resource_group.rg-vnet-south.name
  tags = {
    environment = "south"
  }
  depends_on = [azurerm_resource_group.rg-vnet-south]
}
resource "azurerm_subnet" "net-south-frontend" {
  name = "${var.net-south}-frontend"
  address_prefixes = ["172.20.0.0/24"]
  virtual_network_name = "v${var.net-south}"
  resource_group_name = azurerm_resource_group.rg-vnet-south.name
  depends_on = [azurerm_virtual_network.vnet-south]
}
resource "azurerm_subnet" "net-south-backend" {
  name = "${var.net-south}-backend"
  address_prefixes = ["172.20.1.0/24"]
  virtual_network_name = "v${var.net-south}"
  resource_group_name = azurerm_resource_group.rg-vnet-south.name
  depends_on = [azurerm_virtual_network.vnet-south]
}
resource "azurerm_subnet" "net-web" {
  name = "${var.net-south}-web"
  address_prefixes = ["172.20.2.0/24"]
  virtual_network_name = "v${var.net-south}"
  resource_group_name = azurerm_resource_group.rg-vnet-south.name
  depends_on = [azurerm_virtual_network.vnet-south]
}

locals { // locals for 'next_hop_type' allowed values
  next_hop_type_allowed_values = [
    "VirtualNetworkGateway",
    "VnetLocal",
    "Internet",
    "VirtualAppliance",
    "None"
  ]
}

resource "azurerm_route_table" "rt-net-web" {
  name = "rt-${azurerm_subnet.net-web.name}"
  location = azurerm_resource_group.rg-vnet-south.location
  resource_group_name = azurerm_resource_group.rg-vnet-south.name

  route {
    name = "route-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = local.next_hop_type_allowed_values[3]
    next_hop_in_ip_address = "172.20.1.5"
  }
  route {
    name = "route-to-vnet-addrspace"
    address_prefix = azurerm_virtual_network.vnet-south.address_space[0]
    next_hop_type = local.next_hop_type_allowed_values[1]
  }
}

resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-web" {
  subnet_id = azurerm_subnet.net-web.id
  route_table_id = azurerm_route_table.rt-net-web.id
  depends_on = [azurerm_subnet.net-web,azurerm_route_table.rt-net-web]
}

resource "azurerm_route_table" "frontend" {
  name = azurerm_subnet.net-south-frontend.name
  location = azurerm_resource_group.rg-vnet-south.location
  resource_group_name = azurerm_resource_group.rg-vnet-south.name

  route {
    name = "Local-Subnet"
    address_prefix = azurerm_subnet.net-south-frontend.address_prefixes[0]
    next_hop_type = local.next_hop_type_allowed_values[1]
  }
  route {
    name = "To-Internal"
    address_prefix = "172.20.0.0/22"
    next_hop_type = local.next_hop_type_allowed_values[4]
  }
}

resource "azurerm_subnet_route_table_association" "frontend_association" {
  subnet_id = azurerm_subnet.net-south-frontend.id
  route_table_id = azurerm_route_table.frontend.id
}

resource "azurerm_route_table" "backend" {
  name = azurerm_subnet.net-south-backend.name
  location = azurerm_resource_group.rg-vnet-south.location
  resource_group_name = azurerm_resource_group.rg-vnet-south.name

  route {
    name = "To-Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = local.next_hop_type_allowed_values[4]
  }
}

resource "azurerm_subnet_route_table_association" "backend_association" {
  subnet_id = azurerm_subnet.net-south-backend.id
  route_table_id = azurerm_route_table.backend.id
}

//********************** Network NSG to frontend subnet **************************//
resource "azurerm_network_security_group" "nsg_south_all" {
  name                = "nsg-v${var.net-south}"
  location            = azurerm_resource_group.rg-vnet-south.location
  resource_group_name = azurerm_resource_group.rg-vnet-south.name

  security_rule {
    name                       = "AllowAllInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    description                = "Allow all inbound connections"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "south"
  }
}

resource "azurerm_subnet_network_security_group_association" "security_group_frontend_association" {
  depends_on                = [azurerm_virtual_network.vnet-south, azurerm_subnet.net-south-frontend, azurerm_network_interface.nic_vip, azurerm_network_interface.nic]
  subnet_id                 = azurerm_subnet.net-south-frontend.id
  network_security_group_id = azurerm_network_security_group.nsg_south_all.id
}



# Creation of the Management Hub
resource "azurerm_resource_group" "rg-vnet-secmgmt" {
  name = "cl-v${var.net-secmgmt}"
  location = var.location
}
#resource "azurerm_network_security_group" "nsg-vnet-secmgmt" {
#  name = "nsg-v${var.net-secmgmt}"
#  location = var.location
#  resource_group_name = azurerm_resource_group.rg-vnet-secmgmt.name
#  depends_on = [azurerm_resource_group.rg-vnet-secmgmt]
#}
resource "azurerm_virtual_network" "vnet-secmgmt" {
  name = "v${var.net-secmgmt}"
  address_space = ["172.16.8.0/22"]
  location = var.location
  resource_group_name = azurerm_resource_group.rg-vnet-secmgmt.name
  tags = {
    environment = "management"
  }
  depends_on = [azurerm_resource_group.rg-vnet-secmgmt]
}
resource "azurerm_subnet" "net-secmgmt" {
  name = var.net-secmgmt
  address_prefixes = ["172.16.8.0/24"]
  virtual_network_name = "v${var.net-secmgmt}"
  resource_group_name = azurerm_resource_group.rg-vnet-secmgmt.name
  depends_on = [azurerm_virtual_network.vnet-secmgmt]
}

# Peering from/to Management Hub to Southbound Hub
resource "azurerm_virtual_network_peering" "vnet-secmgmt-to-vnet-south" {
  name = "v${var.net-secmgmt}-to-v${var.net-south}"
  resource_group_name = azurerm_resource_group.rg-vnet-secmgmt.name
  virtual_network_name = "v${var.net-secmgmt}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-south.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-south-to-vnet-secmgmt" {
  name = "v${var.net-south}-to-v${var.net-secmgmt}"
  resource_group_name = azurerm_resource_group.rg-vnet-south.name
  virtual_network_name = "v${var.net-south}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-secmgmt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}
