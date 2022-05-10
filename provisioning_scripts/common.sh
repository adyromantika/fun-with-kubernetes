#!/bin/bash

# Add kubernetes repository to sources.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
echo deb http://apt.kubernetes.io/ kubernetes-xenial main | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

# Add the Docker apt repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install packages
apt-get update
apt-get install -y apt-transport-https ca-certificates software-properties-common gnupg2 \
  kubelet=1.24.0-00 \
  kubeadm=1.24.0-00 \
  kubectl=1.24.0-00 \
  kubernetes-cni=0.8.7-00 \
  containerd.io=1.6.4-1 \
  docker-ce=5:20.10.15~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:20.10.15~3-0~ubuntu-$(lsb_release -cs)

# Set up the Docker daemon https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
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

# Do not disable container runtime
cp /etc/containerd/config.toml /etc/containerd/config.toml.bak
sed -i 's/disabled_plugins.*/disabled_plugins = []/g' /etc/containerd/config.toml
systemctl restart containerd
