module "libvirt_pool" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-pool"
}

module "libvirt_network" {
  source  = "kubealex/libvirt-resources/libvirt//modules/terraform-libvirt-network"
}
