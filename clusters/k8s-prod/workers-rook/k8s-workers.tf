variable "hostname" { default = "k8s-worker" }
variable "domain" { default = "k8s.lab" }
variable "os" { default = "ubuntu" }
variable "memory" { default = 2 }
variable "cpu" { default = 1 }
variable "vm_count" { default = 2 }
variable "rook_volume_size" { default = 10 }
variable "iface" { default = "ens3" }
variable "libvirt_network" { default = "k8s" }
variable "libvirt_pool" { default = "k8s" }
variable "disk_size" { default = 20 }
variable "os_image_name" { default = "CentOS-GenericCloud-worker.qcow2" }

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "os_image" {
  count = var.vm_count
  name = "${var.hostname}-${count.index}-os_image"
  pool = var.libvirt_pool
  source = "/tmp/${var.os_image_name}"
  format = "qcow2"
}

resource "libvirt_volume" "os_image_resized" {
  count = var.vm_count
  name = "${var.hostname}-os_image_resized-${count.index}"
  pool = var.libvirt_pool
  base_volume_id = libvirt_volume.os_image[count.index].id
  size           = var.disk_size*1073741824
}

resource "libvirt_volume" "rook_image" {
  count = var.vm_count
  name = "${var.hostname}-${count.index}-rook_image"
  pool = var.libvirt_pool
  size = var.rook_volume_size*1073741824
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.vm_count
  name = "${var.hostname}-${count.index}-commoninit.iso"
  pool = var.libvirt_pool 
  user_data = data.template_file.user_data[count.index].rendered
}

data "template_file" "user_data" {
  count = var.vm_count
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    network_manager = var.os == "centos" ? "NetworkManager" : "network-manager"
    nfs = var.os == "centos" ? "nfs-utils" : "nfs-common"
    hostname = "${var.hostname}-${count.index}.${var.domain}"
    fqdn = "${var.hostname}-${count.index}.${var.domain}"
   }
}

resource "libvirt_domain" "k8s-worker" {
  autostart = true
  count= var.vm_count
  name = "${var.hostname}-${count.index}"
  memory = var.memory*1024
  vcpu = var.cpu

  disk {
     volume_id = libvirt_volume.os_image_resized[count.index].id
  }

  disk {
     volume_id = libvirt_volume.rook_image[count.index].id
  }

  network_interface {
       network_name = var.libvirt_network
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

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
      version = "0.6.11"
    }
  }
}

output "ips" {
  value = flatten(libvirt_domain.k8s-worker.*.network_interface.0.addresses)
}

output "macs" {
  value = flatten(libvirt_domain.k8s-worker.*.network_interface.0.mac)
}
