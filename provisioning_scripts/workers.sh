#!/bin/bash

NODE_IP=$1

# Change node IP to private network then reload kubelet
sed -iE "s/KUBELET_NETWORK_ARGS=/KUBELET_NETWORK_ARGS=--node-ip=${NODE_IP}\ /" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet

# Join cluster
bash /vagrant/provisioning_scripts/join.sh
