#!/bin/bash

# Reset the worker nodes first since the path to them is through the control plane nodes
talosctl --talosconfig=./talos/clusterconfig/talosconfig reset --reboot -n 192.168.10.71
talosctl --talosconfig=./talos/clusterconfig/talosconfig reset --reboot -n 192.168.10.72
talosctl --talosconfig=./talos/clusterconfig/talosconfig reset --reboot -n 192.168.10.73