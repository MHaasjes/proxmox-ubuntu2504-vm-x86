#!/usr/bin/env bash
set -e

# Parameters
VM_NAME="Ubuntu"
CORES=2
RAM=4096        # MB
DISK_SIZE="16G"
BRIDGE="vmbr0"
STORAGE="local-lvm"  # adjust to your storage
MAC="02:$(openssl rand -hex 5 | sed 's/\(..\)/\1:/g; s/.$//')"

# Find the next free VMID
get_next_vmid() {
  local id=$(pvesh get /cluster/nextid)
  while qm status $id &>/dev/null || [ -f /etc/pve/qemu-server/$id.conf ]; do
    id=$((id+1))
  done
  echo $id
}

# Ensure root
if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

VMID=$(get_next_vmid)

# Download Ubuntu Cloud Image
URL="https://cloud-images.ubuntu.com/plucky/current/plucky-server-cloudimg-amd64.img"
IMG=$(basename "$URL")
curl -fsSL -o "$IMG" "$URL"

# Create VM
qm create $VMID \
  -name $VM_NAME \
  -cores $CORES \
  -memory $RAM \
  -net0 virtio,bridge=$BRIDGE,macaddr=$MAC \
  -scsihw virtio-scsi-pci \
  -ostype l26

# Import disk
qm importdisk $VMID $IMG $STORAGE --format qcow2

# Configure disk, cloud-init and boot
qm set $VMID \
  -scsi0 ${STORAGE}:vm-${VMID}-disk-0,format=qcow2,size=$DISK_SIZE \
  -ide2 ${STORAGE}:cloudinit \
  -boot order=scsi0 \
  -serial0 socket \
  -agent 1

# Start VM
# qm start $VMID

# echo "VM $VM_NAME (ID $VMID) started with $CORES cores, $RAM MB RAM and $DISK_SIZE disk."
