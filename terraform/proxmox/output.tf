output "talosconfig" {
  value     = data.talos_client_configuration.cc.talos_config
  sensitive = true
}

output "cp" {
  value     = data.talos_machine_configuration.mc_1.machine_configuration
  sensitive = true
}

