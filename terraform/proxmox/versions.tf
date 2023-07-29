# TF setup

terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.14"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.2.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
  }
}