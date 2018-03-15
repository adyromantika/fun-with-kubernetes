#!/bin/bash

# Add kubernetes repository to sources.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list

# Install packages
apt-get update
apt-get install -y apt-transport-https docker.io kubelet kubeadm kubectl kubernetes-cni

# Allow vagrant user to use docker commands directly
usermod -a -G docker vagrant
