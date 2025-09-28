#!/bin/bash
export vm_id=202 vm_name="Ubuntu" storage=local-lvm ram=4096 cpu=2 disk_size=16G && \
wget "https://cloud-images.ubuntu.com/plucky/current/plucky-server-cloudimg-amd64.img" -O ubuntu-25.04.qcow2 && \
qm create $vm_id --name $vm_name --ostype l26 && \
qm set $vm_id \
  --net0 virtio,bridge=vmbr0 \
  --serial0 socket \
  --vga serial0 \
  --memory $ram \
  --cores $cpu \
  --cpu host \
  --scsi0 ${storage}:0,import-from="$(pwd)/ubuntu-25.04.qcow2",discard=on \
  --boot order=scsi0 \
  --scsihw virtio-scsi-single \
  --agent enabled=1,fstrim_cloned_disks=1 \
  --ide2 ${storage}:cloudinit \
  --ipconfig0 "ip6=auto,ip=dhcp" \
  --cipassword ${password} \
  --ciuser ${username} && \
qm disk resize $vm_id scsi0 $disk_size && \
rm ubuntu-25.04.qcow2
