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
awkp="/-name $VM_NAME/"
awkp="$awkp && /-hda $(echo $VM_HDD |sed -e 's#/#\\/#g')/"
awkp="$awkp && /-netdev tap,ifname=$VM_MGMT_TAP,id=mgmt/"
awkp="$awkp && /,netdev=mgmt,macaddr=$VM_MGMT_MAC/"
qpid=$(pgrep -a qemu-system-x86 |awk -e "$awkp {print \$1}")
[ $(echo "$qpid" |wc -w) -eq 0 ] && {
echo "VM is probably already stopped: cannot find QEMU pid"!
exit 1
}
[ $(echo "$qpid" |wc -w) -eq 1 ] || {
echo "Could not strictly identify QEMU pid among $qpid, please manually stop VM"!
exit 1
}
ssh $VM_USER@$VM_IP 'poweroff' || {
echo "Will not be able or allowed to poweroff VM on $VM_IP as $VM_USER"!
exit 1
}
ssh $VM_USER@$VM_IP '{ sleep 1 ; poweroff ; } >/dev/null 2>&1 &' || {
echo "Could not poweroff VM on $VM_IP as $VM_USER"!
exit 1
}
while [ -d "/proc/$qpid/" ] ; do
sleep 1
done
ip tuntap del $VM_MGMT_TAP mode tap || {
echo "Could not delete VM management interface $VM_MGMT_TAP"!
exit 1
}
while [ -d "/sys/class/net/$VM_MGMT_TAP/" ] ; do
sleep 1
done
