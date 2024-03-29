machine:
  certSANs:
    - ${apiDomain}
    - ${ipv4_vip}
    - ${ipv4_local}
    - "127.0.0.1" # KubePrism
  kubelet:
    defaultRuntimeSeccompProfileEnabled: true # Enable container runtime default Seccomp profile.
    disableManifestsDirectory: true # The `disableManifestsDirectory` field configures the kubelet to get static pod manifests from the /etc/kubernetes/manifests directory.
    extraArgs:
      feature-gates: GracefulNodeShutdown=true
      rotate-server-certificates: "true"
    nodeIP:
      validSubnets:
        - ${nodeSubnets}
  network:
    hostname: "${hostname}"
    interfaces:
      - interface: eth0
        addresses:
          - ${ipv4_local}/24
        vip:
          ip: ${ipv4_vip}
    nameservers:
        - 192.168.10.1
        - 1.1.1.1
    kubespan:
      enabled: false
    extraHostEntries:
      - ip: ${ipv4_vip}
        aliases:
          - ${apiDomain}
  install:
    disk: /dev/sda
    image: ghcr.io/siderolabs/installer:${talos-version}
    wipe: false
    extensions:
      - image: ghcr.io/siderolabs/qemu-guest-agent:8.1.0
      - image: ghcr.io/siderolabs/i915-ucode:20230310
      - image: ghcr.io/siderolabs/intel-ucode:20230512
      - image: ghcr.io/siderolabs/iscsi-tools:v0.1.4

  files:
    - content: |
        [plugins."io.containerd.grpc.v1.cri"]
          enable_unprivileged_ports = true
          enable_unprivileged_icmp = true
      path: /etc/cri/conf.d/20-customization.part
      op: create
  sysctls:
    net.core.somaxconn: 65535
    net.core.netdev_max_backlog: 4096
  # systemDiskEncryption:
  #   state:
  #     provider: luks2
  #     options:
  #       - no_read_workqueue
  #       - no_write_workqueue
  #     keys:
  #       - nodeID: {}
  #         slot: 0
  #   ephemeral:
  #     provider: luks2
  #     options:
  #       - no_read_workqueue
  #       - no_write_workqueue
  #     keys:
  #       - nodeID: {}
  #         slot: 0
  time:
    servers:
      - 192.168.10.1
  # Features describe individual Talos features that can be switched on or off.
  features:
    rbac: true # Enable role-based access control (RBAC).
    stableHostname: true # Enable stable default hostname.
    apidCheckExtKeyUsage: true # Enable checks for extended key usage of client certificates in apid.
    kubePrism:
      enabled: true
      port: 7445
    kubernetesTalosAPIAccess:
      enabled: true
      allowedRoles:
        - os:admin
      allowedKubernetesNamespaces:
        - system-controllers
  # kernel:
  #   modules:
  #     - name: br_netfilter
  #       parameters:
  #         - nf_conntrack_max=131072
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
  allowSchedulingOnControlPlanes: true
  allowSchedulingOnMasters: true
  controlPlane:
    endpoint: https://${ipv4_vip}:6443
  apiServer:
    admissionControl: []
    disablePodSecurityPolicy: true
    certSANs:
      - ${apiDomain}
      - ${ipv4_vip}
      - "127.0.0.1" # KubePrism
  network:
    dnsDomain: ${domain}
    podSubnets: ${format("%#v",split(",",podSubnets))}
    serviceSubnets: ${format("%#v",split(",",serviceSubnets))}
    cni:
      name: custom
      urls:
        - https://raw.githubusercontent.com/FalkWinkler/home-ops/develop/manifests/talos/cilium.yaml
  proxy:
    disabled: true
  discovery:
    enabled: true
    registries:
      kubernetes:
        disabled: false
      service:
        disabled: false
  # etcd:
  #   advertisedSubnets:
  #     - ${nodeSubnets}
  #   # extraArgs:
  #   #   listen-metrics-urls: http://0.0.0.0:2381
  extraManifests:
    - https://raw.githubusercontent.com/FalkWinkler/home-ops/develop/manifests/talos/cert-approval.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml