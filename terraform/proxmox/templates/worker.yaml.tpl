machine:
  nodeLabels:
    topology.kubernetes.io/region: ${px_region}
    topology.kubernetes.io/zone: ${px_node}
  kubelet:
    defaultRuntimeSeccompProfileEnabled: true # Enable container runtime default Seccomp profile.
    disableManifestsDirectory: true # The `disableManifestsDirectory` field configures the kubelet to get static pod manifests from the /etc/kubernetes/manifests directory.
    extraArgs:
      rotate-server-certificates: true
      node-labels: "project.io/node-pool=worker"
    nodeIP:
      validSubnets: ${format("%#v",split(",",nodeSubnets))}
    clusterDNS:
      - 169.254.2.53
      - ${cidrhost(split(",",serviceSubnets)[0], 10)}
  network:
    hostname: "${hostname}"
    interfaces:
      - interface: eth0
        addresses:
          - ${ipv4_local}/24
      - interface: dummy0
        addresses:
          - 169.254.2.53/32
    extraHostEntries:
      - ip: ${ipv4_vip}
        aliases:
          - ${apiDomain}
  install:
    disk: /dev/sda
    image: ghcr.io/siderolabs/installer:${talos-version}
    bootloader: true
    wipe: false
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
    apidCheckExtKeyUsage: true # Enable checks for extended key usage of client certificates in apid.
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
    endpoint: https://${apiDomain}:6443
  network:
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
        disabled: true
      service:
        disabled: true