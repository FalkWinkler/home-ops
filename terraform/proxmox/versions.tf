# TF setup

terraform {
  required_providers {
    proxmox = {
      source  = "thegameprofi/proxmox"
      version = "2.9.15"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.3.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}