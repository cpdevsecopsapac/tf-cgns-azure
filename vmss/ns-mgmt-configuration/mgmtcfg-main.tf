terraform {
  required_providers {
    checkpoint = {
      source = "checkpointsw/checkpoint"
      version = "~> 1.6.0"
    }
  }
}

# Connecting to ckpmgmt
provider "checkpoint" {
    server = var.mgmt-ip
    username = var.api-username
    password = var.api-password
    context = var.provider-context
    timeout = "180"
}

# Create the localhost object
resource "checkpoint_management_host" "localhost-ip" {
  name = "obj-localhost"
  comments = "Created by Terraform"
  ipv4_address = "127.0.0.1"
  color = "sky blue"
}

# Create the Nginx host object
resource "checkpoint_management_host" "Google-DNS-ip" {
  name         = "Google-DNS"
  ipv4_address = "8.8.8.8"
  comments     = "Created by Terraform"
  color        = "sky blue"
}

# Create the Google DNS host object
resource "checkpoint_management_host" "Nginx-ip" {
  name         = "Nginx-10.0.4.4"
  ipv4_address = "10.0.4.4"
  comments     = "Created by Terraform"
  color        = "sky blue"
}

# Create the host-object with your public IP
resource "checkpoint_management_host" "my-public-ip" {
  name = "my-public-ip"
  comments = "Created by Terraform"
  ipv4_address = var.my-pub-ip
  color = "sky blue"
}

# Create the dynamic-obj: LocalGatewayInternal
resource "checkpoint_management_dynamic_object" "dyn-obj-local-int" {
  name = "LocalGatewayInternal"
  comments = "Created by Terraform"
  color = "sky blue"
}

# Create the dynamic-obj: LocalGatewayExternal
resource "checkpoint_management_dynamic_object" "dyn-obj-local-ext" {
  name = "LocalGatewayExternal"
  comments = "Created by Terraform"
  color = "sky blue"
}

# Cloud Management Extension installation
# already installed by default, so commented this (10/13/2022, R81.10)
#resource "checkpoint_management_run_script" "script-cme" {
#  script_name = "CME Install"
#  script = file("cme_installation.sh")
#  targets = [var.mgmt-name]
#}

# Create a new policy package
resource "checkpoint_management_package" "azure-policy-pkg" {
  name = var.new-policy-pkg
  comments = "Created by Terraform"
  access = true
  threat_prevention = true
  color = "sky blue"
  depends_on = [checkpoint_management_run_script.dc-azure]
}

# Publish the session after the creation of the objects
resource "checkpoint_management_publish" "post-dc-publish" {
  depends_on = [checkpoint_management_host.my-public-ip,checkpoint_management_dynamic_object.dyn-obj-local-ext,
         checkpoint_management_dynamic_object.dyn-obj-local-int,checkpoint_management_package.azure-policy-pkg]
}

# Create the Azure Datacenter
resource "checkpoint_management_run_script" "dc-azure" {
  script_name = "Install Azure DC"
  script = "mgmt_cli add data-center-server name '${var.azure-dc-name}' type 'azure' authentication-method 'service-principal-authentication' application-id '${var.azure-client-id}' application-key '${var.azure-client-secret}' directory-id '${var.azure-tenant}' color 'sky blue' comments 'Created by Terraform' --user '${var.api-username}' --password '${var.api-password}' --version '1.6'"
  targets = [var.mgmt-name]
#  depends_on = [checkpoint_management_run_script.script-cme]
}

# Create the Azure Active Directory
resource "checkpoint_management_run_script" "ad-azure" {
  count = var.mgmt-r81 ? 1 : 0
  script_name = "Connect Azure Active Directory"
  script = "mgmt_cli add azure-ad name '${var.azure-ad-name}' authentication-method 'service-principal-authentication' application-id '${var.azure-client-id}' application-key '${var.azure-client-secret}' directory-id '${var.azure-tenant}' color 'sky blue' comments 'Created by Terraform' --user '${var.api-username}' --password '${var.api-password}' --version '1.7'" 
  targets = [var.mgmt-name]
}

# Create Service Tcp
resource "checkpoint_management_service_tcp" "https-3000" {
  name         = "Port-3000"
  port         = 3000
  protocol     = "ENC-HTTP"
  comments     = "Created by Terraform"
  color        = "sky blue"
}

# Create Service Tcp
resource "checkpoint_management_service_tcp" "https-2999" {
  name         = "Port-2999"
  port         = 2999
  protocol     = "ENC-HTTP"
  comments     = "Created by Terraform"
  color        = "sky blue"
}

# Create network object
resource "checkpoint_management_network" "network-spoke-0" {
  name         = "spoke-0-vnet"
  subnet4      = "10.0.0.0"
  mask_length4 = "22"
  comments     = "Created by Terraform"
  color        = "sky blue"
}

# Create network object
resource "checkpoint_management_network" "network-spoke-1" {
  name         = "spoke-1-vnet"
  subnet4      = "10.0.4.0"
  mask_length4 = "22"
  comments     = "Created by Terraform"
  color        = "sky blue"
}

# Create network group object
resource "checkpoint_management_group" "network-group" {
  name         = "Azure-transit-spokes"
  members      = [ "spoke-0-vnet", "spoke-1-vnet" ]
  depends_on   = [checkpoint_management_network.network-spoke-0, checkpoint_management_network.network-spoke-1]
}

# Install the latest GA Jumbo Hotfix 
resource "checkpoint_management_run_script" "management-jhf-install" {
  script_name = "Download & Install latest JHF"
  script = "clish -c 'installer agent update not-interactive' \n clish -c 'installer check-for-updates not-interactive' \n clish -c 'installer download-and-install '${var.last-jhf}' not-interactive'"
  targets = [var.mgmt-name]
  depends_on = [checkpoint_management_run_script.dc-azure]
}

output "SMS-policy-name" {
  value = resource.checkpoint_management_package.azure-policy-pkg.name
}

output "https-3000-id" {
  description = "returns a string"
  value       = checkpoint_management_service_tcp.https-3000.id
}

output "https-3000" {
  value = checkpoint_management_service_tcp.https-3000
}
