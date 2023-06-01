# Set in this file your deployment variables
azure-client-secret             = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-client-id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-tenant                    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-subscription              = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
location                        = "japaneast"
sku                             = "Standard"

resource_group_name             = "simple-cluster-sms"
cluster_name                    = "cpcluster"
vm_size                         = "Standard_D2_v2"
availability_type               = "Availability Zone"
net-south                       = "net-south"
net-secmgmt                     = "net-mgmt"

admin_username                  = "cpadmin"
admin_password                  = "P>JE3&Hp&r}F{5R?"
sic_key                         = "chkp1SICchkp"
installation_type               = "cluster"
template_name                   = "ha_terraform"
template_version                = "20221123"
enable_custom_metrics           = true
os_version                      = "R81.10"
vm_os_sku                       = "sg-byol"
vm_os_offer                     = "check-point-cg-r8110"
admin_shell                     = "/bin/bash"

# Management details
mgmt-dns-suffix                 = "rbs6lcz"
mgmt-version                    = "r8110"
mgmt-admin-pwd                  = "P>JE3&Hp&r}F{5R?"  // default admin username is "admin", not "cpadmin"
mgmt-name                       = "ckpmgmt"
mgmt-size                       = "Standard_D3_v2"
my-pub-ip                       = "175.177.45.35/32"

# Have you ever deployed a Management or a Cluster in this Subscription?
mgmt-sku-enabled                = true // true when 8110, my company Azure acct. false in other cases
cpcluster-sku-enabled           = true // true when 8110, my company Azure acct. false in other cases

# VMspoke details
apps-name                       = "ckpapps"
vmspoke-sku-enabled             = true
vmspoke-usr                     = "s-user"
vmspoke-pwd                     = "P>JE3&Hp&r}F{5R?"
