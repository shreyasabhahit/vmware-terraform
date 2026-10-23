# ==============================================================================
# VMware vSphere Infrastructure Module - Main Configuration
# Cleanly provisions:
# 1. Dedicated vCenter Folder from scratch
# 2. vCenter Tag Category & Tag from scratch
# 3. Optional Port Group on standard vSwitch with custom VLAN ID
# 4. Optional Secondary Data Disk on Datastore
# 5. Virtual Machine with boot disk, secondary disk, network interface, and tags
# ==============================================================================

# --- Data Sources (Lookups in vCenter) ---
data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  count         = var.cluster_name != "" ? 1 : 0
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  count         = var.host_name != "" ? 1 : 0
  name          = var.host_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "default" {
  count         = (var.cluster_name == "" && var.host_name == "") ? 1 : 0
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "existing_net" {
  count         = var.existing_network_name != "" ? 1 : 0
  name          = var.existing_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  count         = var.template_name != "" ? 1 : 0
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# --- Target Computations ---
locals {
  target_resource_pool_id = (
    var.cluster_name != "" ? data.vsphere_compute_cluster.cluster[0].resource_pool_id :
    (var.host_name != "" ? data.vsphere_host.host[0].resource_pool_id : data.vsphere_resource_pool.default[0].id)
  )

  target_network_id = (
    var.create_portgroup && var.host_name != "" ? vsphere_host_port_group.pg[0].id :
    (var.existing_network_name != "" ? data.vsphere_network.existing_net[0].id : "")
  )
}

# --- 1. vCenter Folder (Created from Scratch) ---
resource "vsphere_folder" "folder" {
  path          = var.vm_folder_name
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# --- 2. vSphere Tags (Created from Scratch) ---
resource "vsphere_tag_category" "category" {
  name        = var.tag_category_name
  description = "Stellaris managed tag category for cloud governance"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "tag" {
  name        = var.tag_name
  category_id = vsphere_tag_category.category.id
  description = "Stellaris managed environment tag"
}

# --- 3. Optional Port Group on vSwitch (Created from Scratch) ---
resource "vsphere_host_port_group" "pg" {
  count               = var.create_portgroup && var.host_name != "" ? 1 : 0
  name                = var.portgroup_name
  host_system_id      = data.vsphere_host.host[0].id
  virtual_switch_name = var.virtual_switch_name
  vlan_id             = var.vlan_id
}

# --- 4. Optional Secondary Data Disk (Created from Scratch) ---
resource "vsphere_virtual_disk" "extra_disk" {
  count      = var.create_data_disk ? 1 : 0
  size       = var.data_disk_size_gb
  vmdk_path  = "${var.vm_name}/data_disk_${var.vm_name}.vmdk"
  datacenter = var.datacenter_name
  datastore  = var.datastore_name
  type       = "thin"
}

# --- 5. Virtual Machine Provisioning ---
resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = local.target_resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path

  num_cpus          = var.num_cpus
  memory            = var.memory_mb
  guest_id          = var.template_name != "" ? data.vsphere_virtual_machine.template[0].guest_id : var.guest_id
  firmware          = var.firmware
  nested_hv_enabled = var.enable_nested_virtualization

  # Network Interface
  dynamic "network_interface" {
    for_each = local.target_network_id != "" ? [local.target_network_id] : []
    content {
      network_id   = network_interface.value
      adapter_type = var.template_name != "" ? data.vsphere_virtual_machine.template[0].network_interface_types[0] : "vmxnet3"
    }
  }

  # Primary Boot Disk
  disk {
    label            = "disk0"
    size             = var.boot_disk_size_gb
    thin_provisioned = var.boot_disk_thin_provisioned
    unit_number      = 0
  }

  # Secondary Attached Data Disk (if created)
  dynamic "disk" {
    for_each = var.create_data_disk ? [1] : []
    content {
      label       = "disk1"
      attach      = true
      path        = vsphere_virtual_disk.extra_disk[0].vmdk_path
      unit_number = 1
    }
  }

  # Governance Tags
  tags = [vsphere_tag.tag.id]

  # Template Clone & Customization (only if template_name is specified)
  dynamic "clone" {
    for_each = var.template_name != "" ? [1] : []
    content {
      template_uuid = data.vsphere_virtual_machine.template[0].id

      dynamic "customize" {
        for_each = var.custom_hostname != "" ? [1] : []
        content {
          linux_options {
            host_name = var.custom_hostname
            domain    = var.custom_domain
          }

          network_interface {
            ipv4_address = var.ipv4_address != "" ? var.ipv4_address : null
            ipv4_netmask = var.ipv4_address != "" ? var.ipv4_netmask : null
          }

          ipv4_gateway    = var.ipv4_gateway != "" ? var.ipv4_gateway : null
          dns_server_list = var.dns_server_list
        }
      }
    }
  }

  # Metadata & Lifecycle
  custom_attributes = {}
  extra_config = {
    "guestinfo.provisioned_by" = "Stellaris Cloud Platform"
  }

  lifecycle {
    ignore_changes = [
      annotation,
      disk[0].io_share_count,
    ]
  }
}
