#!/bin/bash

NODE_IP=$1

# Change node IP to private network then reload kubelet
echo "KUBELET_EXTRA_ARGS=\"--node-ip=${NODE_IP}\"" >> /etc/default/kubelet
systemctl daemon-reload
systemctl restart kubelet

# Join cluster
bash /vagrant/provisioning_scripts/join.sh
