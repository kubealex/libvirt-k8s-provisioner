
# libvirt-k8s-provisioner - Automate your cluster provisioning from 0 to k8s!
Welcome to the home of the project!

- Loadbalancer machine provisioned with:
	- haproxy
- k8s Master(s) VM(s)
- OCP Worker(s) VM(s)

It also takes care of preparing the host machine with needed packages, configuring:
- dedicated libvirt dnsmasq configuration
- dedicated libvirt network (fully customizable)
- dedicated libvirt storage pool (fully customizable) 
- terraform 
- libvirt-terraform-provider ( compiled and initialized based on [https://github.com/dmacvicar/terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt))

## **loadbalancer** VMs spec:

- OS: Centos8 Generic Cloud base image [https://cloud.centos.org/centos/8/x86_64/images/](https://cloud.centos.org/centos/8/x86_64/images/)  
- cloud-init:   
  - user: kube
  - pass: kuberocks  
  - ssh-key: generated during vm-provisioning and stores in the project folder  

The user is capable of logging via SSH too.  

## Quickstart
The playbook is meant to be ran against a/many local or remote host/s, defined under **vm_host** group, depending on how many clusters you want to configure at once.  

    ansible-playbook main.yml

You can quickly make it work by configuring the needed vars, but you can go straight with the defaults!

Recommended values are:

| Role | vCPU | RAM | Storage |
|--|--|--|--|
| master | 4 | 16G | 120G |
| worker | 2 | 8G | 120G |

For testing purposes, minimum storage value is set at **40GB**.

Feel free to suggest modifications/improvements.

Alex
