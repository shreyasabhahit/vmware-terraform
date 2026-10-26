# ==============================================================================
# VMware vSphere Infrastructure Module - Outputs
# ==============================================================================

output "vm_id" {
  description = "UUID of the created virtual machine in vCenter"
  value       = vsphere_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the created virtual machine"
  value       = vsphere_virtual_machine.vm.name
}

output "vm_default_ip_address" {
  description = "Primary IPv4 address assigned to the VM (via DHCP or static guest customization)"
  value       = vsphere_virtual_machine.vm.default_ip_address
}

output "vm_guest_ip_addresses" {
  description = "All IP addresses reported by VMware Tools inside the guest"
  value       = vsphere_virtual_machine.vm.guest_ip_addresses
}

output "vm_folder_path" {
  description = "Path of the created vCenter VM folder"
  value       = vsphere_folder.folder.path
}

output "tag_id" {
  description = "UUID of the created vSphere tag attached to the VM"
  value       = vsphere_tag.tag.id
}

output "portgroup_id" {
  description = "ID of the port group network attached to the VM"
  value       = local.target_network_id
}

output "secondary_disk_path" {
  description = "Path of the secondary data disk attached to the VM (if created)"
  value       = var.create_data_disk ? vsphere_virtual_disk.extra_disk[0].vmdk_path : null
}
