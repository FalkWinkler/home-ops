machine:
  kubelet:
    defaultRuntimeSeccompProfileEnabled: true # Enable container runtime default Seccomp profile.
    disableManifestsDirectory: true # The `disableManifestsDirectory` field configures the kubelet to get static pod manifests from the /etc/kubernetes/manifests directory.
    extraArgs:
      feature-gates: CronJobTimeZone=true,GracefulNodeShutdown=true,NewVolumeManagerReconstruction=false
      rotate-server-certificates: true
      node-labels: "project.io/node-pool=worker"
    nodeIP:
      validSubnets: ${format("%#v",split(",",nodeSubnets))}
  network:
    hostname: "${hostname}"
    interfaces:
      - interface: eth0
        addresses:
          - ${ipv4_local}/24
    nameservers:
        - 192.168.10.1
        - 1.1.1.1
  install:
    disk: /dev/sda
    image: ghcr.io/siderolabs/installer:${talos-version}
    bootloader: true
    wipe: false
    extensions:
      - image: ghcr.io/siderolabs/qemu-guest-agent:8.0.2
  files:
    - content: |
        [plugins."io.containerd.grpc.v1.cri"]
          enable_unprivileged_ports = true
          enable_unprivileged_icmp = true
      path: /var/cri/conf.d/allow-unpriv-ports.toml
      op: create
  sysctls:
    net.core.somaxconn: 65535
    net.core.netdev_max_backlog: 4096
  systemDiskEncryption:
    state:
      provider: luks2
      options:
        - no_read_workqueue
        - no_write_workqueue
      keys:
        - nodeID: {}
          slot: 0
    ephemeral:
      provider: luks2
      options:
        - no_read_workqueue
        - no_write_workqueue
      keys:
        - nodeID: {}
          slot: 0
  time:
    servers:
      - time.cloudflare.com
  # Features describe individual Talos features that can be switched on or off.
  features:
    rbac: true # Enable role-based access control (RBAC).
    stableHostname: true # Enable stable default hostname.
    kubePrism:
      enabled: true
      port: 7445
  kernel:
    modules:
      - name: br_netfilter
        parameters:
          - nf_conntrack_max=131072
  registries:
    mirrors:
      docker.io:
        endpoints:
          - https://${registry-endpoint}/v2/proxy-docker.io
        overridePath: true
      ghcr.io:
        endpoints:
          - https://${registry-endpoint}/v2/proxy-ghcr.io
        overridePath: true
      gcr.io:
        endpoints:
          - https://${registry-endpoint}/v2/proxy-gcr.io
        overridePath: true
      registry.k8s.io:
        endpoints:
          - https://${registry-endpoint}/v2/proxy-registry.k8s.io
        overridePath: true
      quay.io:
        endpoints:
          - https://${registry-endpoint}/v2/proxy-quay.io
        overridePath: true
cluster:
  controlPlane:
    endpoint: https://${ipv4_vip}:6443
  network:
    cni:
      name: none
    dnsDomain: ${domain}
    podSubnets: ${format("%#v",split(",",podSubnets))}
    serviceSubnets: ${format("%#v",split(",",serviceSubnets))}
  apiServer:
    disablePodSecurityPolicy: true
  proxy:
    disabled: true
  discovery:
    enabled: true
    registries:
      kubernetes:
        disabled: false
      service:
        disabled: false