
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
- **network plugin** to use, based on the documentation. 
- **nginx-ingress-controller** if you want to enable ingress management.  
- **@rancher** installation to manage your cluster. 
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
|--|--|--|--|
| master | 2 | 2G | 
| worker | 1 | 1G | 

**vars/k8s_cluster.yml**

    k8s:
      control_plane:
        vcpu: 2
        mem: 2
        vms: 2
      worker_nodes:
        vcpu: 1
        mem: 1
        vms: 1

      network:
        service_cidr: 10.96.0.0/12
        pod_cidr: 10.217.0.0/16
      container_runtime: docker
      master_schedulable: false
      install_nginx: false
      install_rancher: false

Feel free to suggest modifications/improvements.

Alex
