# Set in this file your deployment variables
azure-client-secret             = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-client-id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-tenant                    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-subscription              = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
location                        = "japaneast"
sku                             = "Standard"

resource_group_name             = "simple-cluster"
cluster_name                    = "cpcluster"
vm_size                         = "Standard_D2_v2"
availability_type               = "Availability Zone"
net-south                       = "net-south"

admin_username                  = "cpadmin"
admin_password                  = "P>JE3&Hp&r}F{5R?"
sic_key                         = "chkp1SICchkp"
installation_type               = "cluster"
template_name                   = "ha_terraform"
template_version                = "20221123"
enable_custom_metrics           = true
os_version                      = "R81.20"
vm_os_sku                       = "sg-byol"
vm_os_offer                     = "check-point-cg-r8120"
admin_shell                     = "/bin/bash"

# Have you ever deployed a Management or a Cluster in this Subscription?
cpcluster-sku-enabled           = false
