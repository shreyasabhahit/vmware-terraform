# ==============================================================================
# VMware vSphere Template Clone - Outputs
# ==============================================================================

output "vm_id" {
  description = "Unique Identifier (UUID) of the provisioned Virtual Machine"
  value       = vsphere_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the provisioned Virtual Machine in vCenter"
  value       = vsphere_virtual_machine.vm.name
}

output "vm_default_ip_address" {
  description = "Primary IPv4 address allocated to the Virtual Machine"
  value       = vsphere_virtual_machine.vm.default_ip_address
}

output "vm_guest_id" {
  description = "Guest operating system identifier"
  value       = vsphere_virtual_machine.vm.guest_id
}

output "vm_num_cpus" {
  description = "Number of vCPUs allocated to the Virtual Machine"
  value       = vsphere_virtual_machine.vm.num_cpus
}

output "vm_memory_mb" {
  description = "RAM allocated to the Virtual Machine in MB"
  value       = vsphere_virtual_machine.vm.memory
}
