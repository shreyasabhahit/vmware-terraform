# VMware vSphere Complete Infrastructure Module

A complete, self-contained OpenTofu / Terraform module for VMware vSphere that provisions end-to-end infrastructure from scratch:

1. **vCenter VM Folder** created from scratch to organize Stellaris instances.
2. **vSphere Governance Tags** (Tag Category + Tag) created from scratch and attached to the VM.
3. **Custom Host Port Group** (Optional) created from scratch on a standard vSwitch with a custom VLAN ID.
4. **Dedicated Secondary Virtual Disk** (Optional) provisioned on the Datastore and attached as `/dev/sdb`.
5. **Virtual Machine** with configurable CPU cores, RAM, thin-provisioned root boot disk, network adapter, firmware (BIOS/EFI), and optional Linux guest customization (hostname, static IP/DHCP, DNS).

---

## Architecture Diagram

```
+-------------------------------------------------------------------------+
| vCenter Datacenter                                                      |
|                                                                         |
|  +------------------------+      +------------------------------------+ |
|  | vCenter Folder         |      | vSphere Governance Tag Category    | |
|  | (Stellaris-Workloads)  |      |   -> Tag: Production               | |
|  +-----------+------------+      +-----------------+------------------+ |
|              |                                     |                    |
|              v                                     v                    |
|      +-------------------------------------------------------+          |
|      |               Virtual Machine (VM)                   |          |
|      |                                                       |          |
|      |  - vCPUs: 2 (configurable)                            |          |
|      |  - RAM: 4096 MB (configurable)                        |          |
|      |  - Root Boot Disk: 20 GB (Thin Provisioned)          |          |
|      |  - Secondary Data Volume: 15 GB (Optional)           |          |
|      |  - Network Adapter: VMXNET3                           |          |
|      +---------------------------+---------------------------+          |
|                                  |                                      |
|                                  v                                      |
|          +-----------------------------------------------+              |
|          | Host Port Group (vSwitch0 / Custom VLAN)       |              |
|          +-----------------------------------------------+              |
+-------------------------------------------------------------------------+
```

---

## Input Variables

| Variable | Type | Default | Required | Description |
| :--- | :--- | :--- | :--- | :--- |
| `datacenter_name` | `string` | - | **Yes** | Name of the existing vSphere Datacenter in vCenter (e.g. `Datacenter-1`). |
| `cluster_name` | `string` | `""` | No | Name of the compute cluster (leave empty if using a standalone ESXi host). |
| `host_name` | `string` | `""` | No | Target ESXi host name (required if `cluster_name` is empty). |
| `datastore_name` | `string` | - | **Yes** | Target datastore for VM disks (e.g. `datastore1` or `vsanDatastore`). |
| `existing_network_name`| `string` | `""` | No | Existing port group network to attach (e.g. `VM Network`). |
| `create_portgroup` | `bool` | `false` | No | Set to `true` to provision a brand-new port group on the vSwitch. |
| `portgroup_name` | `string` | `"stellaris-vm-pg"` | No | Name of the new port group if `create_portgroup` is true. |
| `vlan_id` | `number` | `0` | No | VLAN ID for the port group (0 = untagged). |
| `virtual_switch_name` | `string` | `"vSwitch0"` | No | Name of the standard vSwitch on the ESXi host. |
| `template_name` | `string` | `""` | No | Existing VM template in vCenter to clone (e.g. `ubuntu-22.04`). |
| `vm_name` | `string` | `"stellaris-vm"`| No | Name of the VM to create in vCenter. |
| `num_cpus` | `number` | `2` | No | Number of virtual CPUs. |
| `memory_mb` | `number` | `4096` | No | RAM capacity in Megabytes (e.g. 2048, 4096). |
| `boot_disk_size_gb` | `number` | `20` | No | Root boot disk size in GB. |
| `boot_disk_thin_provisioned` | `bool` | `true` | No | Thin provisioned boot disk. |
| `create_data_disk` | `bool` | `false` | No | Create an extra secondary storage disk. |
| `data_disk_size_gb`| `number` | `10` | No | Size of the secondary data volume in GB. |
| `guest_id` | `string` | `"otherLinux64Guest"` | No | Guest OS identifier (e.g. `ubuntu64Guest`). |
| `firmware` | `string` | `"bios"` | No | Firmware mode: `bios` or `efi`. |
| `enable_nested_virtualization` | `bool` | `false` | No | Enable nested hardware virtualization. |
| `custom_hostname` | `string` | `"stellaris-node"` | No | Hostname for guest customization. |
| `ipv4_address` | `string` | `""` | No | Static IP address (leave empty for automatic DHCP). |
| `ipv4_netmask` | `number` | `24` | No | Subnet prefix for static IP (e.g. 24). |
| `ipv4_gateway` | `string` | `""` | No | Default gateway for static IP (leave empty for DHCP). |
| `dns_server_list` | `list(string)` | `["8.8.8.8", "8.8.4.4"]` | No | DNS nameservers for guest customization. |

---

## Outputs

| Output | Description |
| :--- | :--- |
| `vm_id` | UUID of the created VM in vCenter. |
| `vm_name` | Name of the created VM. |
| `vm_default_ip_address` | Primary IPv4 address reported by VMware Tools / DHCP. |
| `vm_guest_ip_addresses` | All assigned guest IP addresses. |
| `vm_folder_path` | Path of the created vCenter VM folder. |
| `tag_id` | UUID of the attached vSphere tag. |
| `portgroup_id` | ID of the port group attached to the VM network adapter. |
| `secondary_disk_path` | Datastore path of the secondary data disk (if created). |
