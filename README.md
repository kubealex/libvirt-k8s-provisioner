[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# libvirt-k8s-provisioner - Automate your cluster provisioning from 0 to k8s!

Welcome to the home of the project!

With this project, you can build up in minutes a fully working k8s cluster (single master/HA) with as many worker nodes as you want.

# DISCLAIMER

It is a hobby project, so it's not supported for production usage, but feel free to open issues and/or contributing to it!

# How does it work?

Kubernetes version that is installed can be choosen between:

- **1.31** - Latest 1.31 release (1.31.0)
- **1.30** - Latest 1.30 release (1.30.4)
- **1.29** - Latest 1.29 release (1.29.8)
- **1.28** - Latest 1.28 release (1.28.13)

Terraform will take care of the provisioning via terraform of:

- Loadbalancer machine with **haproxy** installed and configured for **HA** clusters
- k8s Master(s) VM(s)
- k8s Worker(s) VM(s)

It also takes care of preparing the host machine with needed packages, configuring:

- dedicated libvirt dnsmasq configuration
- dedicated libvirt network (fully customizable)
- dedicated libvirt storage pool (fully customizable)
- libvirt-terraform-provider ( compiled and initialized based on [https://github.com/dmacvicar/terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt))

You can customize the setup choosing:

- **container runtime** that you want to use (**cri-o, containerd**).
- **schedulable master** if you want to schedule on your master nodes or leave the taint.
- **service CIDR** to be used during installation.
- **pod CIDR** to be used during installation.
- **network plugin** to be used, based on the documentation. **[Project Calico](https://www.projectcalico.org/calico-networking-for-kubernetes/)** **[Flannel](https://github.com/coreos/flannel)** **[Project Cilium](https://cilium.io/)**
- **additional SANS** to be added to api-server
- **[nginx-ingress-controller](https://kubernetes.github.io/ingress-nginx/)**, **[haproxy-ingress-controller](https://github.com/haproxytech/kubernetes-ingress)** or **[Project Contour](https://projectcontour.io/)** if you want to enable ingress management.
- **[metalLB](https://metallb.universe.tf/)** to manage bare-metal LoadBalancer services - **WIP** - Only L2 configuration can be set-up via playbook.
- **[Rook-Ceph](https://rook.io/docs/rook/v1.4/ceph-storage.html)** - To manage persistent storage, also configurable with single storage node.

## All VMs are specular,prepared with:

- OS:

  - Ubuntu 22.04 LTS Cloud base image [https://cloud-images.ubuntu.com/releases/jammy/release/](https://cloud-images.ubuntu.com/releases/jammy/release/)
  - Centos Stream 9 Generic Cloud base image [https://cloud.centos.org/centos/9-stream/x86_64/images/](https://cloud.centos.org/centos/9-stream/x86_64/images/)

- cloud-init:
  - user: **kube**
  - pass: **kuberocks**
  - ssh-key: generated during vm-provisioning and stores in the project folder

The user is capable of logging via SSH too.

## Quickstart

The playbook is meant to be ran against a local host or a remote host that has access to subnets that will be created, defined under **vm_host** group, depending on how many clusters you want to configure at once.

First of all, you need to install required collections to get started:

```bash
ansible-galaxy collection install -r requirements.yml
```

Once the collections are installed, you can simply run the playbook:

```bash
ansible-playbook main.yml
```

You can quickly make it work by configuring the needed vars, but you can go straight with the defaults!

You can also install your cluster using the **Makefile** with:

To install collections:

```bash
make setup
```

To install the cluster:

```bash
make create
```

## Quickstart with Execution Environment

The playbooks are compatible with the newly introduced **Execution environments (EE)**. To use them with an execution environment you need to have [ansible-builder](https://ansible-builder.readthedocs.io/en/stable/) and [ansible-navigator](https://ansible-navigator.readthedocs.io/en/latest/) installed.

### Build EE image

To build the EE image, jump in the _execution-environment_ folder and run the build:

```bash
ansible-builder build -f execution-environment/execution-environment.yml -t k8s-ee
```

### Run playbooks

To run the playbooks use ansible navigator:

```bash
ansible-navigator run main.yml -m stdout
```

## Recommended sizing

Recommended sizings are:

| Role   | vCPU | RAM |
| ------ | ---- | --- |
| master | 2    | 2G  |
| worker | 2    | 2G  |

**vars/k8s_cluster.yml**

```yaml

# General configuration

    k8s:
      cluster_name: k8s-test
      cluster_os: Ubuntu
      cluster_version: 1.31
      container_runtime: crio
      master_schedulable: false

    # Nodes configuration

      control_plane:
        vcpu: 2
        mem: 2
        vms: 3
        disk: 30

      worker_nodes:
        vcpu: 2
        mem: 2
        vms: 1
        disk: 30

    # Network configuration

      network:
        network_cidr: 192.168.200.0/24
        domain: k8s.test
        additional_san: ""
        pod_cidr: 10.20.0.0/16
        service_cidr: 10.110.0.0/16
        cni_plugin: cilium

    rook_ceph:
      install_rook: false
      volume_size: 50
          rook_cluster_size: 1

    # Ingress controller configuration [nginx/haproxy]

    ingress_controller:
      install_ingress_controller: true
      type: haproxy
          node_port:
            http: 31080
            https: 31443

    # Section for metalLB setup

    metallb:
      install_metallb: false
      l2:
      iprange: 192.168.200.210-192.168.200.250
```

Size for **disk** and **mem** is in GB.
**disk** allows to provision space in the cloud image for pod's ephemeral storage.

**cluster_version** can be 1.28, 1.29, 1.30, 1.31 to install the corresponding latest version for the release

VMS are created with these names by default (customizing them is work in progress):

```bash
- **cluster_name**-loadbalancer.**domain**
- **cluster_name**-master-N.**domain**
- **cluster_name**-worker-N.**domain**
```

It is possible to choose **CentOS**/**Ubuntu** as **kubernetes hosts OS**

## Multiple clusters - Thanks to @3rd-st-ninja for the input

Since last release, it is now possible to provision multiple clusters on the same host. Each cluster will be self consistent and will have its own folder under the /**/home/user/k8ssetup/clusters** folder in playbook root folder.

```bash
    clusters
    └── k8s-provisioner
    	├── admin.kubeconfig
    	├── haproxy.cfg
    	├── id_rsa
    	├── id_rsa.pub
    	├── libvirt-resources
    	│   ├── libvirt-resources.tf
    	│   └── terraform.tfstate
    	├── loadbalancer
    	│   ├── cloud_init.cfg
    	│   ├── k8s-loadbalancer.tf
    	│   └── terraform.tfstate
    	├── masters
    	│   ├── cloud_init.cfg
    	│   ├── k8s-master.tf
    	│   └── terraform.tfstate
    	├── workers
    	│   ├── cloud_init.cfg
    	│   ├── k8s-workers.tf
    	│   └── terraform.tfstate
    	└── workers-rook
    	    ├── cloud_init.cfg
    	    └── k8s-workers.tf
```

In the main folder will be provided a custom script for removing the single cluster, without touching others.

```bash
k8s-provisioner-cleanup-playbook.yml
```

As well as a separated inventory for each cluster:

```bash
k8s-provisioner-inventory-k8s
```

In order to keep clusters separated, ensure that you use a different **k8s.cluster_name**,**k8s.network.domain** and **k8s.network.network_cidr** variables.

## Rook

**Rook** setup actually creates a dedicated kind of worker, with an additional volume on the VMs that are required. Now it is possible to select the size of Rook cluster using **rook_ceph.rook_cluster_size** variable in the settings.

## MetalLB

Basic setup taken from the documentation. At the moment, the parameter **l2** reports the IPs that can be used (defaults to some IPs in the same subnet of the hosts) as 'external' IPs for accessing the applications

Suggestion and improvements are highly recommended!
Alex
