# -*- mode: ruby -*-
# vi: set ft=ruby :

# Size of the cluster created by Vagrant
num_instances = 3

# Network prefix
network_prefix = "172.31.99."

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  # config.vm.box = "bento/ubuntu-16.04"
  config.vm.provision "shell", path: "provisioning_scripts/common.sh"

  # Launch kube-master
  config.vm.define "kube-master" do |master|
    master.vm.hostname = "kube-master"
    master.vm.network "private_network", ip: "#{network_prefix}10"
    master.vm.provider :virtualbox do |vb|
      vb.memory = "2560"
      vb.cpus = "2"
      vb.name = "kube-master"
    end
    master.vm.provision "shell", inline: "/bin/bash /vagrant/provisioning_scripts/master.sh #{network_prefix}"
  end

  # Launch kube-worker-{index} up to num_instances specified
  (1..num_instances).each do |i|
    vm_name = "%s-%02d" % ["kube-worker", i]
    vm_ip = "#{network_prefix}#{i+10}"
    config.vm.define vm_name do |worker|
      worker.vm.hostname = vm_name
      worker.vm.network "private_network", ip: vm_ip
      worker.vm.provider :virtualbox do |vb|
        vb.memory = "1536"
        vb.cpus = "1"
        vb.name = vm_name
      end
      worker.vm.provision "shell", inline: "/bin/bash /vagrant/provisioning_scripts/workers.sh #{vm_ip}"
    end
  end
end
