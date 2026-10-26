# ==============================================================================
# VMware vSphere Template Clone - Input Variables
# ==============================================================================

variable "datacenter_name" {
  type        = string
  description = "Name of the vSphere Datacenter in vCenter (e.g. DC)"
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "Name of the compute cluster in vCenter (leave empty if using standalone ESXi host)"
}

variable "host_name" {
  type        = string
  default     = ""
  description = "FQDN or IP of the target ESXi host in vCenter (required if cluster_name is empty)"
}

variable "datastore_name" {
  type        = string
  description = "Name of the target Datastore for VM storage (e.g. DS-01)"
}

variable "network_name" {
  type        = string
  description = "Name of the existing vSphere Port Group network (e.g. 172_16_1_0_24)"
}

variable "template_name" {
  type        = string
  description = "Name of the existing VM template in vCenter to clone (e.g. ubuntu2404)"
}

variable "vm_name" {
  type        = string
  description = "Name of the new Virtual Machine to create in vCenter"
}

variable "num_cpus" {
  type        = number
  description = "Number of virtual CPUs (vCPU cores)"
}

variable "memory_mb" {
  type        = number
  description = "Amount of dedicated RAM in Megabytes (e.g. 4096 for 4GB, 8192 for 8GB)"
}

variable "boot_disk_size_gb" {
  type        = number
  default     = 0
  description = "Size of the root boot disk in GB (set 0 to keep the template's default disk size)"
}

variable "custom_hostname" {
  type        = string
  default     = ""
  description = "Guest OS hostname for Linux customization (optional, leave empty to clone directly without OS customization)"
}

variable "custom_domain" {
  type        = string
  default     = "local"
  description = "Domain name for Linux guest customization"
}
