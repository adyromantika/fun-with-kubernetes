#!/bin/bash

NETWORK_PREFIX=$1

# Init
kubeadm init --apiserver-advertise-address ${NETWORK_PREFIX}10 --pod-network-cidr 192.168.0.0/16 | tee /home/vagrant/kubeadm.log

# Change node IP to private network then reload kubelet
echo "KUBELET_EXTRA_ARGS=\"--node-ip=${NETWORK_PREFIX}10\"" >> /etc/default/kubelet
systemctl daemon-reload
systemctl restart kubelet

# Copy kubectl config for root
mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config

# Copy kubectl config for vagrant user
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown 1000:1000 /home/vagrant/.kube/config

# Copy to default shared directory so that it is easier to get from the host
cp -i /etc/kubernetes/admin.conf /vagrant/kube_config

# Copy join command to shared folder to be used by workers
tail -2 /home/vagrant/kubeadm.log > /vagrant/provisioning_scripts/join.sh

# Install helm
curl -L https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install network plugin
helm repo add projectcalico https://projectcalico.docs.tigera.io/charts
helm install calico projectcalico/tigera-operator --version v3.22.2
