variable "kubernetes" {
  type = map(string)
  default = {
    hostname                = ""
    podSubnets              = "10.244.0.0/16"
    serviceSubnets          = "10.96.0.0/12"
    nodeSubnets             = "192.168.10.0/24"
    domain                  = "cluster.local"
    apiDomain               = ""
    ipv4_local              = ""
    ipv4_vip                = ""
    talos-version           = ""
    metallb_l2_addressrange = ""
    registry-endpoint       = ""
    identity                = ""
    identitypub             = ""
    knownhosts              = ""
    px_region               = ""
    px_node                 = ""
    sidero-endpoint         = ""
    storageclass            = ""
    storageclass-xfs        = ""
    cluster-0-vip           = ""
    gateway                 = "192.168.1.1"
  }
}

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "admin"
}

variable "region" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "cluster-1"
}

variable "pool" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "prod"
}

variable "cluster_endpoint" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "https://api.domain.local:6443"
}

variable "talos_version" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "v1.4.6"
}

variable "k8s_version" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "v1.27.3"
}

variable "proxmox_host" {
  description = "Proxmox host"
  type        = string
  default     = "192.168.10.254"
}

variable "proxmox_image" {
  description = "Proxmox source image name"
  type        = string
  default     = "talos"
}

variable "proxmox_storage1" {
  description = "Proxmox storage name"
  type        = string
}

variable "proxmox_storage2" {
  description = "Proxmox storage name"
  type        = string
}

variable "proxmox_token_id" {
  description = "Proxmox token id"
  type        = string
}

variable "proxmox_token_secret" {
  description = "Proxmox token secret"
  type        = string
}

variable "first_ip" {
  type = string
}
variable "worker_first_ip" {
  type = string
}

variable "vpc_main_cidr" {
  description = "Local proxmox subnet"
  type        = string
  default     = "192.168.10.0/24"
}

variable "gateway" {
  type    = string
  default = "192.168.10.1"
}

variable "nameserver" {
  type        = string
  description = "die Ip Adresse des Nameserver"
  default     = "192.168.10.1"
}


variable "search_domain" {
  type        = string
  description = "die Such Domain"
  default     = "home.lan"
}


variable "target_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "private_key_file_path" {
  type = string
}

variable "public_key_file_path" {
  type = string
}

variable "known_hosts" {
  type = string
}

variable "nodes" {
  type = list(string)
  default = [ "pve","pve2","pve3" ]
}

variable "node_ssds" {
  type = list(string)
  default = [ "/dev/disk/by-id/ata-CT500MX500SSD1_2324E6E25F94","/dev/disk/by-id/ata-CT500MX500SSD1_2314E6C44636","/dev/disk/by-id/ata-CT500MX500SSD1_2324E6E25F90" ]
}