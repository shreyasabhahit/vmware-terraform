# ==============================================================================
# VMware vSphere Infrastructure Module - Variables
# ==============================================================================

# --- Target vSphere Environment ---
variable "datacenter_name" {
  type        = string
  description = "Name of the existing vSphere Datacenter in vCenter (e.g. Datacenter-1)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the compute cluster in vCenter (optional, leave empty if using standalone ESXi host)"
  default     = ""
}

variable "host_name" {
  type        = string
  description = "FQDN or IP of the target ESXi host in vCenter (required if cluster_name is empty or for host-specific resources)"
  default     = ""
}

variable "datastore_name" {
  type        = string
  description = "Name of the target Datastore for VM storage (e.g. datastore1, vsanDatastore)"
}

variable "virtual_switch_name" {
  type        = string
  description = "Name of the standard virtual switch on the ESXi host (e.g. vSwitch0)"
  default     = "vSwitch0"
}

variable "existing_network_name" {
  type        = string
  description = "Name of an existing vSphere port group network to use (leave empty if creating a new port group from scratch)"
  default     = ""
}

variable "template_name" {
  type        = string
  description = "Name of the existing VM template in vCenter to clone (optional, leave empty to provision a fresh VM without cloning)"
  default     = ""
}

# --- Resources Created from Scratch ---
variable "create_portgroup" {
  type        = bool
  description = "Whether to provision a new standard port group from scratch on the vSwitch"
  default     = false
}

variable "portgroup_name" {
  type        = string
  description = "Name of the newly created port group"
  default     = "stellaris-vm-pg"
}

variable "vlan_id" {
  type        = number
  description = "VLAN ID for the newly created port group (0 for untagged / default, 1-4094 for tagged)"
  default     = 0
}

variable "vm_folder_name" {
  type        = string
  description = "Name of the dedicated vCenter VM Folder to create from scratch"
  default     = "Stellaris-Workloads"
}

variable "tag_category_name" {
  type        = string
  description = "Name of the vSphere Tag Category to create from scratch"
  default     = "Stellaris-Environment"
}

variable "tag_name" {
  type        = string
  description = "Name of the vSphere Tag to create from scratch"
  default     = "Production"
}

variable "create_data_disk" {
  type        = bool
  description = "Whether to create a dedicated secondary virtual disk volume on the datastore from scratch"
  default     = false
}

variable "data_disk_size_gb" {
  type        = number
  description = "Size of the secondary data disk in GB"
  default     = 10
}

# --- Virtual Machine Compute Specs ---
variable "vm_name" {
  type        = string
  description = "Name of the Virtual Machine to create in vCenter"
  default     = "stellaris-vm"
}

variable "num_cpus" {
  type        = number
  description = "Number of virtual CPUs (vCPU cores)"
  default     = 2
}

variable "memory_mb" {
  type        = number
  description = "Amount of dedicated RAM in Megabytes (e.g. 2048 for 2GB, 4096 for 4GB)"
  default     = 4096
}

variable "boot_disk_size_gb" {
  type        = number
  description = "Size of the root boot disk in Gigabytes"
  default     = 20
}

variable "boot_disk_thin_provisioned" {
  type        = bool
  description = "Whether the boot disk uses thin provisioning (recommends true to conserve physical storage)"
  default     = true
}

variable "guest_id" {
  type        = string
  description = "vSphere guest OS identifier (e.g. ubuntu64Guest, rhel8_64Guest, otherLinux64Guest)"
  default     = "otherLinux64Guest"
}

variable "firmware" {
  type        = string
  description = "Firmware type for the VM: bios or efi"
  default     = "bios"
}

variable "enable_nested_virtualization" {
  type        = bool
  description = "Enable hardware-assisted nested virtualization for hypervisors inside the VM"
  default     = false
}

# --- Guest OS Customization (Applied When Cloning a Template) ---
variable "custom_hostname" {
  type        = string
  description = "Linux guest hostname when cloning from template"
  default     = "stellaris-node"
}

variable "custom_domain" {
  type        = string
  description = "Domain name for Linux guest customization"
  default     = "local"
}

variable "ipv4_address" {
  type        = string
  description = "Static IPv4 address to assign to the VM (leave empty for automatic DHCP)"
  default     = ""
}

variable "ipv4_netmask" {
  type        = number
  description = "IPv4 CIDR netmask prefix for static IP (e.g. 24 for 255.255.255.0)"
  default     = 24
}

variable "ipv4_gateway" {
  type        = string
  description = "Default IPv4 gateway address (leave empty for DHCP)"
  default     = ""
}

variable "dns_server_list" {
  type        = list(string)
  description = "List of DNS nameservers for guest OS resolution"
  default     = ["8.8.8.8", "8.8.4.4"]
}
