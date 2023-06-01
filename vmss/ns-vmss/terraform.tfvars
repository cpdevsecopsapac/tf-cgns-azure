# Set in this file your deployment variables
# Specify the Azure values
azure-client-id     = "required"
azure-client-secret = "required"
azure-subscription  = "required"
azure-tenant        = "required"

# Specify where you want to deploy it and where you are coming from
location                = "francecentral"

# VMSS details
vmss-sku-enabled        = true
#vmss-version            = "r8110"
vmss-name               = "north-vmss"
vmss-password           = "P>JE3&Hp&r}F{5R?"
vmss-min-members        = "2"
vmss-max-members        = "5"
vmss-zones-number       = "3"
vmss-vnet               = "net-north"
vmss-template           = "my-template-for-north"
vmss-admin-alert        = "scottl@checkpoint.com"
vmss-vmsize             = "Standard_DS2_v2"
vmss-sic                = "chkp1SICchkp"
vmss-cgns-offer         = "R81.20 - Bring Your Own License"

# Management details
mgmt-name               = "ckpmgmt"
mgmt-ip                 = "this is needed"
api-username            = "admin"
api-password            = "P>JE3&Hp&r}F{5R?"
provider-context        = "web_api"

new-policy-pkg          = "pkg-azure"
mgmt-controller         = "Azure-demo"
