vpc_main_cidr         = "192.168.10.0/24"            # nodes subnet
gateway               = "192.168.10.1"               # subnet gateway
first_ip              = "31"                      # first ip address of the master-1 node - 10.1.1.5
worker_first_ip       = "34"                      # first ip address of the worker-1 node - 10.1.1.8
proxmox_storage1      = "local-zfs"                    # proxmox storage lvm 1
proxmox_storage2      = "local-zfs"                   # proxmox storage lvm 2
k8s_version           = "v1.27.3"                # k8s version
proxmox_image         = "talos"                  # talos image created by packer
talos_version         = "v1.5.1"                   # talos version for machineconfig gen
cluster_endpoint      = "https://home-cluster.home.lan:6443" # cluster endpoint to fetch via talosctl
region                = "cluster-1"              # proxmox cluster name
pool                  = "prod"                   # proxmox pool for vms
private_key_file_path = "~/.ssh/id_rsa"          # fluxcd git creds for ssh
public_key_file_path  = "~/.ssh/id_rsa.pub"      # fluxcd git creds for ssh
known_hosts           = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="

kubernetes = {
  podSubnets              = "10.244.0.0/16"       # pod subnet
  serviceSubnets          = "10.96.0.0/12"        # svc subnet
  nodeSubnets             = "192.168.10.0/24"     # nodes subnet
  domain                  = "cluster.local"       # cluster local kube-dns svc.cluster.local
  ipv4_vip                = "192.168.10.30"           # vip ip address
  apiDomain               = "home-cluster.home.lan"   # cluster endpoint
  talos-version           = "v1.5.1"              # talos installer version
  metallb_l2_addressrange = "192.168.10.50-192.168.10.70" # metallb L2 configuration ip range
  registry-endpoint       = "reg.f-wi.com"   # set registry url for cache image pull
  gateway                 = "192.168.10.1"
}