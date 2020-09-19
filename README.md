[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# libvirt-k8s-provisioner - Automate your cluster provisioning from 0 to k8s!
Welcome to the home of the project!

With this project, you can build up in minutes a fully working k8s cluster (single master/HA) with as many worker nodes as you want.

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

- **container runtime** that you want to use (docker, cri-o, containerd).
- **schedulable master** if you want to schedule on your master nodes or leave the taint.
- **service CIDR** to be used during installation. 
- **pod CIDR** to be used during installation. 
- **network plugin** to be used, based on the documentation. **[Project Calico](https://www.projectcalico.org/calico-networking-for-kubernetes/)** **[Flannel](https://github.com/coreos/flannel)**
- **[nginx-ingress-controller](https://kubernetes.github.io/ingress-nginx/)** or **[haproxy-ingress-controller](https://github.com/haproxytech/kubernetes-ingress)** if you want to enable ingress management.  
- **[Rancher](https://rancher.com/)** installation to manage your cluster. 
- **[Rook-Ceph](https://rook.io/docs/rook/v1.4/ceph-storage.html)** - **WIP**

## All VMs are specular,prepared with:

- OS: Centos7 Generic Cloud base image [https://cloud.centos.org/centos/8/x86_64/images/](https://cloud.centos.org/centos/7/images/)  
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
	  container_runtime: crio
	  master_schedulable: false

	# Nodes configuration

	  control_plane:
	    vcpu: 1
            mem: 2
	    vms: 3
	    disk: 30

	  worker_nodes:
	    vcpu: 1
	    mem: 2
	    vms: 3
	    disk: 30

	# Network configuration

	  network:
	    pod_cidr: 10.200.0.0/16
	    service_cidr: 10.50.0.0/16
	    cni_plugin: calico

	# Rook configuration

	rook_ceph:
	  install_rook: false
	  volume_size: 50

	# Ingress controller configuration [nginx/haproxy]

	ingress_controller:
	  install_ingress_controller: true
	  type: nginx

	rancher:
 	  install_rancher: false

Size for **disk** and **mem** is in GB. 
**disk** allows to provision space in the cloud image for pod's ephemeral storage. 

VMS are created with these names by default (customizing them is work in progress):

	- k8s-loadbalancer.**domain**
	- k8s-master-N.**domain**
	- k8s-worker-N.**domain**

These are the default for libvirt resources:

**vars/libvirt.yml**

	libvirt:
	  network:
	    domain: k8s.lab
	    name: k8s
	    net: 192.168.200.0/24
	  storage:
	    pool_name: k8s
	    pool_path: /var/lib/libvirt/images/k8s

Feel free to suggest modifications/improvements.

Alex
