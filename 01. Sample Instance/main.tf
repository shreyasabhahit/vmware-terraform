# ==============================================================================
# VMware vSphere Virtual Machine Provisioning from Existing Template
# ==============================================================================

# --- Data Sources: Environment Lookups ---
data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  count         = var.cluster_name != "" ? 1 : 0
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  count         = var.cluster_name == "" && var.host_name != "" ? 1 : 0
  name          = var.host_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# --- Resolve Target Resource Pool ---
locals {
  target_resource_pool_id = (
    var.cluster_name != "" ? data.vsphere_compute_cluster.cluster[0].resource_pool_id :
    data.vsphere_host.host[0].resource_pool_id
  )
}

# --- Virtual Machine Cloned from Template ---
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = local.target_resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.num_cpus
  memory   = var.memory_mb
  guest_id = data.vsphere_virtual_machine.template.guest_id
  firmware = data.vsphere_virtual_machine.template.firmware

  # Network Interface (inherits adapter type from template e.g. vmxnet3)
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Primary Boot Disk (inherits size from template or expands if boot_disk_size_gb is specified)
  disk {
    label            = "disk0"
    size             = var.boot_disk_size_gb > 0 ? var.boot_disk_size_gb : data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  # Clone configuration
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    # Optional OS Customization (only runs when custom_hostname is provided)
    dynamic "customize" {
      for_each = var.custom_hostname != "" ? [1] : []
      content {
        linux_options {
          host_name = var.custom_hostname
          domain    = var.custom_domain
        }
        network_interface {}
      }
    }
  }

  lifecycle {
    ignore_changes = [
      annotation,
      disk[0].io_share_count,
    ]
  }
}
