#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

source ./vm-args.sh
# qemu-img create -f qcow2 -o preallocation=metadata $VM_HDD 40G
fallocate -l 20G $VM_HDD
qemu-img info $VM_HDD

# Checking CPU topology
$RTE_SDK/tools/cpu_layout.py

#  Copy and adjust Python helper script, used to start VM, from PROX
cd /opt/crucio/PROX
git checkout a52953c4a92ecfcfdd06fc01fce42b57f998cb10
cd -
cp -a /opt/crucio/PROX/helper-scripts/start_vm.py _62-start-vm-helper.py
chmod +x _62-start-vm-helper.py
cur_path="$(pwd)"
cd /opt/dats-patchs
git checkout master
patch -p1 </opt/dats-patchs/common-patchs/patch/prox/start-vm-helper.patch
git checkout crucio-scripts
cd $cur_path

# Get management interface

# If this fails, manually set MGMT_IF
MGMT_IF=$($RTE_BIND --status |sed -n -e '/\*Active\*/ s/^.* if=\([^ ]*\) .*$/\1/p')
[ $(echo "$MGMT_IF" |wc -w) -eq 1 ] && echo "OK, management interface is: $MGMT_IF" || echo "Please manually set MGMT_IF"

# Create VM management interface, attach it to management bridge and bring it up
ip tuntap del dev $VM_MGMT_TAP mode tap	
ip tuntap add $VM_MGMT_TAP mode tap
echo "MGMT_IF=$MGMT_IF"
echo "MGMT_BR=$MGMT_BR"
echo "VM_MGMT_TAP=$VM_MGMT_TAP"
brctl addif $MGMT_BR $VM_MGMT_TAP
ip link set $VM_MGMT_TAP up
