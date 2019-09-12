#!/bin/bash

NETWORK_PREFIX=$1

# Init
kubeadm init --apiserver-advertise-address ${NETWORK_PREFIX}10 --pod-network-cidr 192.168.0.0/16 | tee /home/vagrant/kubeadm.log

# Change node IP to private network then reload kubelet
sed -iE "s/KUBELET_NETWORK_ARGS=/KUBELET_NETWORK_ARGS=--node-ip=${NETWORK_PREFIX}10\ /" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet

# Copy kubectl config for root
mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config

# Copy kubectl config for vagrant user
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown 1000:1000 /home/vagrant/.kube/config

# Copy join command to shared folder to be used by workers
tail -2 /home/vagrant/kubeadm.log > /vagrant/provisioning_scripts/join.sh

# Install network plugin
kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml

# Install and initialize helm
curl -L https://git.io/get_helm.sh | bash
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account tiller
