terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.7.4"
    }
  }
}

provider "proxmox" {
    pm_api_url      = join("", [var.pm_api_url, ":8006/api2/json"])
    pm_user         = var.pm_user
    pm_password     = var.pm_user_password
    pm_tls_insecure = "true"
}

resource "proxmox_vm_qemu" "test-vm-" {
  count = 1
  name = "test-vm-${count.index + 1}"
  target_node = var.pm_host
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 1
  sockets = 1
  cpu = "kvm64"
  memory = 2048
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "10G"
    type = "scsi"
    storage = var.pm_storage
  }
  
  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  ipconfig0 = "ip=192.168.174.20${count.index + 1}/24,gw=192.168.174.2"
  
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}