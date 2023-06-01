//#PLEASE refer to the README.md for accepted values FOR THE VARIABLES BELOW
#client_secret                   = ""                                     # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#client_id                       = ""                                         # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#tenant_id                       = ""                                         # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#subscription_id                 = ""                                   # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
source_image_vhd_uri            = "noCustomUri"               # "noCustomUri"
resource_group_name             = "myCGNSRG"                               # "checkpoint-ha-terraform"
cluster_name                    = "myCGNSCluster"                                      # "checkpoint-ha-terraform"
location                        = "japaneast"                                          # "eastus"
vnet_name                       = "myCNGSvnet"                              # "checkpoint-ha-vnet"
address_space                   = "10.0.0.0/16"                     # "10.0.0.0/16"
subnet_prefixes                 = ["10.0.1.0/24","10.0.2.0/24"]                      # ["10.0.1.0/24","10.0.2.0/24"]
admin_password                  = "RoE8'QQ4Mcd:"                                    # "xxxxxxxxxxxx"
sic_key                         = "sic1n1tauthpass"                                           # "xxxxxxxxxxxx"
vm_size                         = "Standard_D2_v2"                                           # "Standard_D3_v2"
disk_size                       = "100"                                         # "110"
vm_os_sku                       = "sg-byol"                                            # "sg-byol"
vm_os_offer                     = "check-point-cg-r8110"                                          # "check-point-cg-r8110"
os_version                      = "R81.10"                                   # "R81.10"
bootstrap_script                = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
allow_upload_download           = true                                     # true
authentication_type             = "Password"                               # "Password"
availability_type               = "Availability Zone"                                 # "Availability Zone" or "Availability Set"
enable_custom_metrics           = true                                     # true
enable_floating_ip              = false                                     # false
use_public_ip_prefix            = false                                     # false
create_public_ip_prefix         = false                                     # false
existing_public_ip_prefix_id    = ""                             # ""
admin_shell                     = "/etc/cli.sh"                                       # "/etc/cli.sh"