resource "proxmox_vm_qemu" "controlplanes" {
  count       = 3
  name        = "node${count.index + 1}"
  #target_node = var.target_node_name
  target_node     = element(var.nodes, count.index)
  clone       = var.proxmox_image

  agent                   = 1
  define_connection_info  = false
  os_type                 = "cloud-init"
  qemu_os                 = "l26"
  ipconfig0               = "ip=${cidrhost(var.vpc_main_cidr, var.first_ip + "${count.index}")}/24,gw=${var.gateway}"
  cloudinit_cdrom_storage = var.proxmox_storage1
  searchdomain = var.search_domain
  nameserver   = var.nameserver

  onboot  = true
  cpu     = "host"
  sockets = 1
  cores   = element(var.node_cpu, count.index)
  memory  = element(var.node_ram, count.index)#4096
  scsihw  = "virtio-scsi-pci"
  tags    = "talos,k8s"

  vga {
    memory = 0
    type   = "std"
  }
  serial {
    id   = 0
    type = "socket"
  }

  network {
    model    = "virtio"
    bridge   = "vmbr1"
    firewall = false
  }

  boot = "order=scsi0"
  # disk {
  #   type    = "scsi"
  #   storage = var.proxmox_storage1
  #   size    = "100G"
  #   cache   = "writethrough"
  #   ssd     = 1
  #   backup  = false
  # }
  #   disk {
  #   type    = "scsi"
  #   storage = var.proxmox_storage2
  #   size    = "120G"
  #   cache   = "writethrough"
  #   ssd     = 1
  #   backup  = false
  # }

  lifecycle {
    ignore_changes = [
      boot,
      network,
      desc,
      numa,
      agent,
      ipconfig0,
      ipconfig1,
      define_connection_info,
    ]
  }
}