# VMware vSphere VM from Existing Template

A modular OpenTofu / Terraform module to provision a Virtual Machine in VMware vCenter by cloning an existing VM template (such as `ubuntu2404`).

## Features
- Clones directly from existing vSphere VM templates.
- Automatically inherits network adapter type, firmware type (`bios` / `efi`), and guest OS ID from the template.
- Supports standalone ESXi hosts or DRS Compute Clusters.
- Dynamically resizes the boot disk if specified, or preserves the template's original disk size.
- Optional Linux guest customization (hostname, domain) via cloud-init / open-vm-tools.

## Requirements
- OpenTofu >= 1.6 or Terraform >= 1.0
- VMware vSphere Provider `~> 2.6`
