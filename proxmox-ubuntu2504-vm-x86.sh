#!/bin/bash
export vm_id=202 vm_name="Ubuntu" storage=local-lvm ram=4096 cpu=2 disk_size=16G && \
wget -O ubuntu-25.04.qcow2 "https://cloud-images.ubuntu.com/plucky/current/plucky-server-cloudimg-amd64.img" && \
qm create $vm_id --name $vm_name --ostype l26 && \
qm importdisk $vm_id ubuntu-25.04.qcow2 $storage && \
qm set $vm_id \
  --scsihw virtio-scsi-single \
  --scsi0 ${storage}:vm-${vm_id}-disk-0,discard=on \
  --net0 virtio,bridge=vmbr0 \
  --serial0 socket \
  --vga serial0 \
  --memory $ram \
  --cores $cpu \
  --cpu host \
  --boot order=scsi0 \
  --agent enabled=1,fstrim_cloned_disks=1 \
  --ide2 ${storage}:cloudinit \
  --ipconfig0 "ip6=auto,ip=dhcp" && \
qm disk resize $vm_id scsi0 $disk_size && \
rm ubuntu-25.04.qcow2
