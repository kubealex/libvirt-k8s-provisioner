variable "hostname" { default = "k8s-master" }
variable "domain" { default = "k8s.lab" }
variable "os" { default = "ubuntu" }
variable "memory" { default = 4 }
variable "cpu" { default = 1 }
variable "iface" { default = "ens3" }
variable "libvirt_network" { default = "k8s" }
variable "libvirt_pool" { default= "k8s" }
variable "disk_size" { default = 25 }
variable "os_image_name" { default= "CentOS-GenericCloud.qcow2" }
variable "sshKey" { default = "" }

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "os_image" {
  name = "${var.hostname}-os_image"
  pool = var.libvirt_pool
  source = "/tmp/${var.os_image_name}"
  format = "qcow2"
}

resource "libvirt_volume" "os_image_resized" {
  name = "${var.hostname}-os_image_resized"
  pool = var.libvirt_pool
  base_volume_id = libvirt_volume.os_image.id
  size           = var.disk_size*1073741824
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
    sshKey = var.sshKey
   }
}

resource "libvirt_domain" "k8s-loadbalancer" {
  autostart = true
  name = var.hostname
  memory = var.memory*1024
  vcpu = var.cpu

  disk {
     volume_id = libvirt_volume.os_image_resized.id
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
      version = "0.7.0"
    }
  }
}

output "ips" {
  value = flatten(libvirt_domain.k8s-loadbalancer.*.network_interface.0.addresses)
}

output "macs" {
  value = flatten(libvirt_domain.k8s-loadbalancer.*.network_interface.0.mac)
}
