output "control_plane_config_mac_addrs" {
    value = {for vm, config in proxmox_vm_qemu.talos-control-plane-node : vm => config.network[0].macaddr}
}