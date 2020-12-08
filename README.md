[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# libvirt-k8s-provisioner - Automate your cluster provisioning from 0 to k8s!
Welcome to the home of the project!

With this project, you can build up in minutes a fully working k8s cluster (single master/HA) with as many worker nodes as you want.

Kubernetes version that is installed is **1.19.x**

Terraform will take care of the provisioning of:
- Loadbalancer machine with **haproxy** installed and configured for **HA** clusters
- k8s Master(s) VM(s)
- k8s Worker(s) VM(s)

It also takes care of preparing the host machine with needed packages, configuring:

- dedicated libvirt dnsmasq configuration
- dedicated libvirt network (fully customizable)
- dedicated libvirt storage pool (fully customizable) 
- terraform 
- libvirt-terraform-provider ( compiled and initialized based on [https://github.com/dmacvicar/terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt))

You can customize the setup choosing:

- **container runtime** that you want to use (**docker, cri-o, containerd** actually available).
- **schedulable master** if you want to schedule on your master nodes or leave the taint.
- **service CIDR** to be used during installation. 
- **pod CIDR** to be used during installation. 
- **network plugin** to be used, based on the documentation. **[Project Calico](https://www.projectcalico.org/calico-networking-for-kubernetes/)** **[Flannel](https://github.com/coreos/flannel)**
- **[nginx-ingress-controller](https://kubernetes.github.io/ingress-nginx/)** or **[haproxy-ingress-controller](https://github.com/haproxytech/kubernetes-ingress)** if you want to enable ingress management.  
- **[Rancher](https://rancher.com/)** installation to manage your cluster. 
- **[metalLB](https://metallb.universe.tf/)** to manage bare-metal LoadBalancer services - **WIP** - Only L2 configuration can be set-up via playbook.
- **[Rook-Ceph](https://rook.io/docs/rook/v1.4/ceph-storage.html)** - **WIP - To be improved, current rook-ceph cluster size is 3 nodes**

## All VMs are specular,prepared with:

- OS: 
  - Centos7 Generic Cloud base image [https://cloud.centos.org/centos/7/images/](https://cloud.centos.org/centos/7/images/)  
  - Centos8 Generic Cloud base image [https://cloud.centos.org/centos/8/x86_64/images/](https://cloud.centos.org/centos/8/x86_64/images/)  

- cloud-init: 
  - user: kube
  - pass: kuberocks  
  - ssh-key: generated during vm-provisioning and stores in the project folder  

The user is capable of logging via SSH too.  

## Quickstart
The playbook is meant to be ran against a/many local or remote host/s, defined under **vm_host** group, depending on how many clusters you want to configure at once.  

    ansible-playbook main.yml

You can quickly make it work by configuring the needed vars, but you can go straight with the defaults!

Recommended sizings are:

| Role | vCPU | RAM |
|--|--|--|
| master | 2 | 2G | 
| worker | 1 | 1G | 

**vars/k8s_cluster.yml**

# General configuration
	k8s:
	  cluster_name: k8s-test
	  cluster_os: CentOS7
	  container_runtime: crio
	  master_schedulable: false

	# Nodes configuration

	  control_plane:
	    vcpu: 2
	    mem: 2 
	    vms: 3
	    disk: 30

	  worker_nodes:
	    vcpu: 1
	    mem: 1
	    vms: 1
	    disk: 30

	# Network configuration

	  network:
	    network_cidr: 192.168.200.0/24
	    domain: k8s.test
	    pod_cidr: 10.20.0.0/16
	    service_cidr: 10.110.0.0/16
	    cni_plugin: calico

	# Rook configuration

	rook_ceph:
	  install_rook: false
	  volume_size: 50

	# Ingress controller configuration [nginx/haproxy]

	ingress_controller:
	  install_ingress_controller: true
	  type: haproxy

	# Section for Rancher setup

	rancher:
	  install_rancher: true

	# Section for metalLB setup

	metallb:
	  install_metallb: false
	  manifest_url: https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests
	  l2: 192.168.200.210-192.168.200.250

Size for **disk** and **mem** is in GB. 
**disk** allows to provision space in the cloud image for pod's ephemeral storage. 

VMS are created with these names by default (customizing them is work in progress):

	- **cluster_name**-loadbalancer.**domain**
	- **cluster_name**-master-N.**domain**
	- **cluster_name**-worker-N.**domain**

It is possible to choose CentOS7/CentOS8 as **kubernetes hosts OS**

##Rook
**Rook** setup actually creates a dedicated kind of worker, with an additional volume on **ALL** workers to be used. It will be improved to just select a number of nodes that can be coherent with the number of **ceph** replicas.
Feel free to suggest modifications/improvements.

##Rancher
Basic setup is made starting from Rancher documentation, with **Helm** chart.

##MetalLB
Basic setup taken from the documentation. At the moment, the parameter **l2** reports the IPs that can be used (defaults to some IPs in the same subnet of the hosts) as 'external' IPs for accessing the applications

Suggestion and improvements are highly recommended!
Alex
