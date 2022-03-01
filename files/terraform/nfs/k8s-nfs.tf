variable "hostname" { default = "k8s-nfs" }
variable "domain" { default = "k8s.lab" }
variable "os" { default = "ubuntu" }
variable "memory" { default = 4 }
variable "cpu" { default = 1 }
variable "iface" { default = "ens3" }
variable "libvirt_network" { default = "k8s" }
variable "libvirt_pool" { default= "k8s" }
variable "nfs_fsSize" { default = 50 }
variable "os_image_name" { default= "CentOS-GenericCloud.qcow2" }

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "os_image" {
  name = "${var.hostname}-os_image"
  pool = var.libvirt_pool
  source = "/tmp/${var.os_image_name}"
  format = "qcow2"
}

resource "libvirt_volume" "nfs_fs" {
  name = "${var.hostname}-nfs_fs"
  pool = var.libvirt_pool
  size = var.nfs_fsSize*1073741824
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name = "${var.hostname}-commoninit.iso"
  pool = var.libvirt_pool 
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    network_manager = var.os == "centos" ? "NetworkManager" : "network-manager"
    hostname = "${var.hostname}.${var.domain}"
    fqdn = "${var.hostname}.${var.domain}"
   }
}

resource "libvirt_domain" "k8s-nfs" {
  autostart = true
  name = var.hostname
  memory = var.memory*1024
  vcpu = var.cpu

  disk {
     volume_id = libvirt_volume.os_image.id
  }

  disk {
     volume_id = libvirt_volume.nfs_fs.id
  }

  network_interface {
       network_name = var.libvirt_network
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

terraform {
 required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

output "ips" {
  value = flatten(libvirt_domain.k8s-nfs.*.network_interface.0.addresses)
}

output "macs" {
  value = flatten(libvirt_domain.k8s-nfs.*.network_interface.0.mac)
}
