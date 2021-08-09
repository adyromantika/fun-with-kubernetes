#!/bin/bash

# Add kubernetes repository to sources.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list

# Install packages
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2 \
  kubelet=1.22.0-00 \
  kubeadm=1.22.0-00 \
  kubectl=1.22.0-00 \
  kubernetes-cni=0.8.7-00

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add the Docker apt repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CE
apt-get update && apt-get install -y \
  containerd.io=1.4.9-1 \
  docker-ce=5:20.10.8~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:20.10.8~3-0~ubuntu-$(lsb_release -cs)

# Set up the Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl enable docker.service
systemctl restart docker

# Allow vagrant user to use docker commands directly
usermod -a -G docker vagrant
