# Set in this file your deployment variables
# Specify the Azure values
azure-client-id     = "no need if using Terraform cloud"
azure-client-secret = "no need if using Terraform cloud"
azure-subscription  = "no need if using Terraform cloud"
azure-tenant        = "no need if using Terraform cloud"

# Specify where you want to deploy it and where you are coming from
location                = "France Central"
my-pub-ip               = "this is needed" // e.g. "175.177.45.35/32"

# Management details
mgmt-sku-enabled        = true
mgmt-dns-suffix         = "give some random string such as kaylc5"
mgmt-version            = "r8120"
mgmt-admin-pwd          = "P>JE3&Hp&r}F{5R?"  // default admin username is "admin"

# VMspoke details
vmspoke-sku-enabled     = true
vmspoke-usr             = "s-user"
vmspoke-pwd             = "P>JE3&Hp&r}F{5R?"
spokes-default-gateway  = "172.16.1.4"
