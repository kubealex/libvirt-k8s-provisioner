module "libvirt_pool" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-pool"
  version = "0.0.1"
  pool_name = var.pool_name
}

module "libvirt_network" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-network"
  version = "0.0.1"
  network_name = var.network_name
  network_domain = var.network_domain
  network_cidr = var.network_cidr
  network_dhcp_enabled = var.network_dhcp_enabled
  network_dhcp_local = var.network_dhcp_local
  network_dnsmasq_options = var.network_dnsmasq_options
}


module "master_nodes" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-instance"
  version = "0.0.1"
  instance_libvirt_network = var.instance_libvirt_network
  instance_libvirt_pool = var.instance_libvirt_pool
  instance_cloud_image = var.instance_cloud_image
  instance_hostname = var.instance_hostname
  instance_domain = var.instance_domain
  instance_memory = var.instance_memory
  instance_cpu = var.instance_cpu
  instance_count = var.instance_count
  instance_cloud_user = var.instance_cloud_user
}

module "worker_nodes" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-instance"
  version = "0.0.1"
  instance_libvirt_network = var.instance_libvirt_network
  instance_libvirt_pool = var.instance_libvirt_pool
  instance_cloud_image = var.instance_cloud_image
  instance_hostname = var.instance_hostname
  instance_domain = var.instance_domain
  instance_memory = var.instance_memory
  instance_cpu = var.instance_cpu
  instance_count = var.instance_count
  instance_cloud_user = var.instance_cloud_user
}