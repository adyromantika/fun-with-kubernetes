# Fun with Kubernetes

Purpose: Single node examples and minikube do not reflect real multi-node Kubernetes environments. It'd be fun and useful to have a multi-node environment to study and run test on, to emulate real world setup.

Let's launch a local Kubernetes. Requirements:

* [Vagrant](https://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

## End Results

* Ubuntu 20.04 machines (focal64)
* Kubernetes 1.24

## Quick Start

```shell
git glone https://github.com/adyromantika/fun-with-kubernetes
cd fun-with-kubernetes
vagrant up
vagrant ssh kube-master
kubectl get pod -A
```

With the default `num_instances`, when Vagrant is done provisioning all virtual machines, we get something like this:

```shell
user@host-machine:~$ vagrant ssh kube-master

vagrant@kube-master:~$ kubectl get pod --all-namespaces -o wide
NAMESPACE     NAME                                       READY     STATUS              RESTARTS   AGE       IP                NODE
kube-system   calico-etcd-4hcsl                          1/1       Running             0          6h        172.31.99.10      kube-master
kube-system   calico-kube-controllers-559b575f97-psqsw   1/1       Running             0          6h        172.31.99.10      kube-master
kube-system   calico-node-6xr7z                          0/2       ContainerCreating   0          25s       172.31.99.13      kube-worker-03
kube-system   calico-node-fw2m7                          2/2       Running             1          2m        172.31.99.12      kube-worker-02
kube-system   calico-node-pb84k                          2/2       Running             1          6h        172.31.99.10      kube-master
kube-system   calico-node-x8j9c                          2/2       Running             1          5m        172.31.99.11      kube-worker-01
kube-system   etcd-kube-master                           1/1       Running             0          6h        172.31.99.10      kube-master
kube-system   kube-apiserver-kube-master                 1/1       Running             0          6h        172.31.99.10      kube-master
kube-system   kube-controller-manager-kube-master        1/1       Running             0          6h        172.31.99.10      kube-master
kube-system   kube-dns-6f4fd4bdf-gjmds                   3/3       Running             0          6h        192.168.221.193   kube-master
kube-system   kube-proxy-8dl6v                           1/1       Running             0          6h        172.31.99.10      kube-master
kube-system   kube-proxy-brpvh                           1/1       Running             0          25s       172.31.99.13      kube-worker-03
kube-system   kube-proxy-ttn46                           1/1       Running             0          2m        172.31.99.12      kube-worker-02
kube-system   kube-proxy-vlmkd                           1/1       Running             0          5m        172.31.99.11      kube-worker-01
kube-system   kube-scheduler-kube-master                 1/1       Running             0          6h        172.31.99.10      kube-master
```

## Networking

Each virtual machine has:

* The default NAT interface (10.0.2.0/24). This is created automatically by VirtualBox, and is where the nodes get Internet connection (default route).
* A private network (172.31.99.0/24) shared between them. This is where the nodes communicate with each other, as well with the VirtualBox host.
* Calico uses pod network (192.168.0.0/16) by default so that is what we passed to `kubeadm` during init.

To expose services later we have a few options:

* Have a new public network interface to access from outside of the private network
* Create a load balancer within the private network to handle connections to and from the public network

The `kube-apiserver` is listening on all interfaces by default (0.0.0.0) so that we can access it using `kubectl` from the **host** by specifying the endpoint `https://192.168.56.10:6443`. The file `~/.kube/config` from `kube-master` can be used on the host machine directly .

## What's Included

* Network plugin with default configuration - [Calico](https://www.projectcalico.org/calico-networking-for-kubernetes/)
* Package manager - [Helm](https://helm.sh)

## Customizations

Change `num_instances` in `Vagrantfile` to have more nodes in the cluster.

```ruby
# Size of the cluster created by Vagrant
num_instances=3
```

## Changelog

* 10 May 2022:
  * Vagrant box updated to Focal Fossa (20.04)
  * Update package versions
  * Use Helm 3 (no more tiller!)

* 10 August 2021:
  * Lock Kubernetes package versions to ensure compatibility
  * Update Docker package versions
  * Update changed api endpoints in kubernetes 1.22 for traefik chart

* 23 July 2020:
  * Changed Vagrant box to Bionic Beaver (18.04). Focal Fossa has trouble with Vagrant at the moment (a known bug)
  * Modify apiVersion for deployment of Traefik ingress in the Helm chart template
  * Update Docker [as recommended by Kubernetes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker)
  * Update method of passing node IP variable to kubernetes startup script
