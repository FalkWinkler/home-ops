#!/bin/bash

talhelper genconfig -c talos/talconfig.yaml -e talos/talenv.sops.yaml -o talos/clusterconfig

# Configure the control-plane nodes
talosctl apply-config --insecure -n 192.168.10.71  -f talos/clusterconfig/home-cluster-talos-node-1.yaml
talosctl apply-config --insecure -n 192.168.10.72  -f talos/clusterconfig/home-cluster-talos-node-2.yaml
talosctl apply-config --insecure -n 192.168.10.73  -f talos/clusterconfig/home-cluster-talos-node-3.yaml

# cp ./talos/clusterconfig/talosconfig  '$HOME/.talos/config' 

# talosctl --talosconfig=./talos/clusterconfig/talosconfig config endpoint 192.168.10.71 #192.168.10.72 192.168.10.73
# talosctl config merge ./talosconfig

# It will take a few minutes for the nodes to spin up with the configuration.  Once ready, execute
# talosctl --talosconfig=./talos/clusterconfig/talosconfig bootstrap -n 192.168.10.71

# It will then take a few more minutes for Kubernetes to get up and running on the nodes. Once ready, execute
# talosctl --talosconfig=./talos/clusterconfig/talosconfig kubeconfig -n 192.168.10.71