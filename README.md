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
- **service** CIDR to use during installation. 
- **pod** CIDR to use during installation. 
- **network plugin** to use, based on the documentation. **Defaults to Calico.** (WIP)
- **[nginx-ingress-controller](https://kubernetes.github.io/ingress-nginx/)** if you want to enable ingress management.  
- **[Rancher](https://rancher.com/)** installation to manage your cluster. 
- **master schedulable** if you want to schedule on your master nodes or leave the taint.


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

	k8s:
	  control_plane:
	    vcpu: 2
	    mem: 4
	    vms: 2
	    disk: 10

	  worker_nodes:
	    vcpu: 1
	    mem: 2
	    vms: 1
	    disk: 10

	  network:
	    pod_cidr: 10.200.0.0/16
	    service_cidr: 10.50.0.0/16
	    cni_plugin: calico

	  container_runtime: docker
	  master_schedulable: false
	  install_nginx: false
	  install_rancher: false

Size for **disk** and **mem** is in GB. **disk** allows to provision space for pod's ephemeral storage.

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
