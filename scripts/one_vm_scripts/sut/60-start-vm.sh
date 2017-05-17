#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

source ./vm-args.sh
ip tuntap add $VM_MGMT_TAP mode tap || {
echo "Could not create VM management interface $VM_MGMT_TAP"!
exit 1
}
brctl addif $MGMT_BR $VM_MGMT_TAP || {
echo "Could not attach VM management interface $VM_MGMT_TAP to management bridge $MGMT_BR"!
exit 1
}
ip link set $VM_MGMT_TAP up || {
echo "Could not bring VM management interface $VM_MGMT_TAP up"!
exit 1
}
args="-enable-kvm -cpu host -name $VM_NAME -hda $VM_HDD -vnc :$VM_VNC"
args="$args -net nic,model=virtio,netdev=mgmt,macaddr=$VM_MGMT_MAC"
args="$args -netdev tap,ifname=$VM_MGMT_TAP,id=mgmt,vhost=on,script=no,downscript=$VM_MGMT_DOWN"
args="$args -object memory-backend-file,id=mem,size=$VM_RAM,mem-path=/dev/hugepages,share=on"
args="$args -m $VM_RAM -numa node,memdev=mem -mem-prealloc"
for p in p{0,1,2,3} ; do
chardev="sock_$p"
netdev="vhost_$p"
mac="VM_VHOST_MAC_$p"
mac="${!mac}"
args="$args -chardev socket,id=$chardev,path=$OVS_SOCKDIR/$p"
args="$args -netdev type=vhost-user,id=$netdev,chardev=$chardev,vhostforce"
args="$args -device virtio-net-pci,mac=$mac,netdev=$netdev"
args="$args,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off"
done
./_62-start-vm-helper.py $args && ./_63-after-vm-boot.sh
