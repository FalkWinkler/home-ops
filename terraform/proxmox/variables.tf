
variable "proxmox_host_node" {
    default = "pve"
    description = "The name of the proxmox node where the cluster will be deployed"
    type = string
}

variable "proxmox_api_url" {
    default = "https://192.168.10.254:8006/api2/json"
    description = "The URL for the Proxmox API."
    type = string
}

# Setting these here so it can be used in root module's .tfvars files.
#variable "ceph_mon_disk_storage_pool" {}
#variable "proxmox_debug" {}