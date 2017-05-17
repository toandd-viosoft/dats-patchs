#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

path="$(pwd)"
args=""
args="$args -enable-kvm -cpu host"
args="$args -name $VM_NAME -hda $VM_HDD -vnc :$VM_VNC"
args="$args -net nic,model=virtio,netdev=mgmt,macaddr=$VM_MGMT_MAC"
args="$args -netdev tap,ifname=$VM_MGMT_TAP,id=mgmt,vhost=on,script=no,downscript=$path/$VM_MGMT_DOWN"
args="$args -m $VM_RAM"
./_62-start-vm-helper.py $args
