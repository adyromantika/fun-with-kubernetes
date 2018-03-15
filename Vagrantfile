# -*- mode: ruby -*-
# vi: set ft=ruby :

# Size of the cluster created by Vagrant
num_instances=3

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  # config.vm.box = "bento/ubuntu-16.04"
  config.vm.provision "shell", inline: <<-SHELL
    # Install packages
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
    echo deb http://apt.kubernetes.io/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y apt-transport-https docker.io kubelet kubeadm kubectl kubernetes-cni
    # Allow vagrant user to use docker commands directly
    usermod -a -G docker vagrant
  SHELL

  config.vm.define "master" do |master|
    master.vm.hostname = "kube-master"
    master.vm.network "private_network", ip: "172.31.99.10"
    master.vm.provider :virtualbox do |vb|
      vb.memory = "2560"
      vb.cpus = "2"
      vb.name = "kube-master"
    end
    master.vm.provision "shell", inline: <<-SHELL
      # Init
      kubeadm init --apiserver-advertise-address 172.31.99.10 --pod-network-cidr 192.168.0.0/16 | tee /home/vagrant/kubeadm.log
      # Change node IP to private network then reload kubelet
      sed -iE 's/KUBELET_NETWORK_ARGS=/KUBELET_NETWORK_ARGS=--node-ip=172.31.99.10\ /' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
      systemctl daemon-reload
      systemctl restart kubelet
      # Copy kubectl config for root
      mkdir -p /root/.kube
      sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
      # Copy kubectl config for vagrant user
      mkdir -p /home/vagrant/.kube
      cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
      chown 1000:1000 /home/vagrant/.kube/config
      # Copy join command to be used by workers
      cat /home/vagrant/kubeadm.log | grep 'kubeadm join' > /vagrant/join.sh
      # Install network plugin
      kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
    SHELL
  end

  (1..num_instances).each do |i|
    vm_name = "%s-%02d" % ["kube-worker", i]
    vm_ip = "172.31.99.#{i+10}"
    config.vm.define vm_name do |worker|
      worker.vm.hostname = vm_name
      worker.vm.network "private_network", ip: vm_ip
      worker.vm.provider :virtualbox do |vb|
        vb.memory = "1536"
        vb.cpus = "1"
        vb.name = vm_name
      end
      worker.vm.provision "shell", inline: <<-SHELL
        # Change node IP to private network then reload kubelet
        sed -iE 's/KUBELET_NETWORK_ARGS=/KUBELET_NETWORK_ARGS=--node-ip=#{vm_ip}\ /' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        systemctl daemon-reload
        systemctl restart kubelet
        # Join cluster
        bash /vagrant/join.sh
      SHELL
    end
  end
end
