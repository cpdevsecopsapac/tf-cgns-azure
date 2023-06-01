# Set in this file your deployment variables
# Specify the Azure values
azure-client-id     = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-client-secret = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-subscription  = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-tenant        = "xxxxx-xxxxx-xxxxx-xxxxx"

# Specify where you want to deploy it and where you are coming from
location                = "France Central"
my-pub-ip               = "175.177.xx.xx/32"
mydns-zone              = "demoscott.link"

# Management details
mgmt-sku-enabled        = true      # Have you ever deployed a R81.10 CKP management? Set to false if not
mgmt-dns-suffix         = "v0qdt"
#mgmt-admin-pwd          = "pwd"

# VMspoke details
vmspoke-sku-enabled     = true      # Have you ever deployed a Nginx VM before? set to false if not
#vmspoke-usr             = "testuser"
#vmspoke-pwd             = "pwd"

# Cluster Details
cpcluster-sku-enabled   = true     # Have you ever deployed a R80.40 CKP cluster? set to false if not
admin_username          = "admin"
admin_password          = "forever young"
sic_key                 = "chkp1SICchkp"

# GWLB VMSS Details
gwlb-vmss-agreement     = true      # Have you ever deployed a GWLB VMSS? set to false if not
chkp-admin-usr          = "cpadmin"
chkp-admin-pwd          = "forever young"
chkp-sic                = "chkp1SICchkp"
gwlb-name               = "ckpgwlbvmss" # this will be used as configurationTemplate, and will be used in autoprov_cfg init


# added by Scott
availability_type       = "Availability Zone"
number_of_vm_instances  = "2"
vm_size                 = "Standard_D2_v2"
authentication_type     = "Password"
admin_shell             = "/bin/bash"
lb_probe_protocol       = "Tcp" # one of [Http Https Tcp]
cluster_name            = "cpcluster"
resource_group_name     = "gwlb_cpcluster" # used for cluster south hub
