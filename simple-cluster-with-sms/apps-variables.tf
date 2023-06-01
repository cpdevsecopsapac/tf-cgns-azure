variable "apps-name" {
    description = "Choose the name of the management"
    default = "ckpapps"
}

variable "vmspoke-name" {
    default = "vmspoke"
}

variable "vmspoke-publisher" {
    default = "bitnami"
}

variable "vmspoke-offer" {
    default = "nginxstack"
}

variable "vmspoke-sku" {
    default = "1-9"
}

variable "vmspoke-sku-enabled" {
    description = "Have you ever deployed this vm spoke before? set to false if not"
    type = bool
    default = false
}
variable "vmspoke-usr" {
    description = "Set the user for login to vmspoke machines"
    type = string
}
variable "vmspoke-pwd" {
    description = "Set the password for login to vmspoke machines"    
    type = string
    sensitive = true
}