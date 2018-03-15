# Fun with Kubernetes

Purpose: Single node examples and minikube doesn't reflect real multi-node Kubernetes environments. It'd be fun and useful to have a multi-node environment to study and run test on, to emulate real world setup.

Let's launch a local Kubernetes cluster on Ubuntu 16.04. Requirements:

* [Vagrant](https://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

## Quick Start

```
git glone https://github.com/adyromantika/fun-with-kubernetes
cd fun-with-kubernetes
vagrant up
```

With the default `num_instances`, when Vagrant is done provisioning all virtual machines, we get something like this:

```
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

* The default NAT interface (10.0.2.0/24). This is used internally by Vagrant, and is where the nodes get Internet connection.
* A private network (172.31.99.0/24) shared between them. This is where the nodes communicate with each other.
* Calico uses pod network (192.168.0.0/16) by default so that is what we passed to `kubeadm` during init.

To expose services later we have a few options:

* Have a new public network interface to access from outside of the private network
* Create a load balancer within the private network to handle connections to and from the public network

Also, we might change kubeapi to listen to all interfaces (0.0.0.0) so that we can access it using `kubectl` from outside of the cluster.

## What's Included

* Network plugin with default configuration - [Calico](https://www.projectcalico.org/calico-networking-for-kubernetes/)

## Future Plan

* [Helm](https://helm.sh) charts
  * Ingress controller
  * Sample services (i.e. web, nginx)

## Customizations

Change `num_instances` in `Vagrantfile` to have more nodes in the cluster.

```
# Size of the cluster created by Vagrant
num_instances=3
```
