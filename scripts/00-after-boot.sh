#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: 
#    To be executed after each boot
#	Load uio and igb_uio or vfio-pci kernel modules
#	Unbind bound ports to allow using script at any time
#	Bind selected ports
#	Report ports status
#    Note:
#	No need to mount hugepages, already mounted on /dev/hugepages (with Redhat)
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################


path="$(pwd)"
#source $path/env.sh

# Get the name of NIC card, which can connect to internet
NET=$(route | grep '^default' | grep -o '[^ ]*$')
ipaddr=$(ifconfig $NET  | grep -ie "inet" | grep -ioEe "([0-9]+\.){3}[0-9]+")
ipaddr=($ipaddr)
IP=${ipaddr[0]}
#Shouldn't bind the NIC card which was being used to access internet, get its pci address
black_pci=(`ethtool -i $NET | grep bus-info | cut -d':' -f3-5`)
#black_pci=(`$RTE_SDK/tools/dpdk_nic_bind.py -s | grep Active |cut -d':' -f2-4`)
pci_port_type=(`lspci | grep Ether | grep $PCI_TYPE | cut -d' ' -f1`)
num_pci_ports=${#pci_port_type[@]}

#Mount hugepage if OS is debean
if [ -f /etc/network/interfaces ]
then
[ -d /dev/hugepages ] || mkdir -p /dev/hugepages
umount `awk '/hugetlbfs/ { print $2 }' /proc/mounts` >/dev/null 2>&1
echo 16 > /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages
echo 16 > /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
echo 4096 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
echo 4096 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
mount -t hugetlbfs nodev /dev/hugepages
fi

#Binding nic cards to dpdk driver, checking whether server has enough pci ports or not
if [ $num_pci_ports -ge $NUMB_OF_PCI_PORTS ]
then
    echo "Using igb_uio driver"
cd $path

  if [ $DPDK_DRIVER = igb_uio ]
  then
    lsmod |grep -w "^uio" >/dev/null 2>&1 || modprobe uio
    lsmod |grep -w "^igb_uio" >/dev/null 2>&1 || insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko
    port=0
    while [ $port -lt $NUMB_OF_PCI_PORTS ]
    do
        $RTE_BIND -u ${pci_port_type[$port]}
        $RTE_BIND -b igb_uio ${pci_port_type[$port]}
        port=`expr $port + 1`
    done
    $RTE_BIND --status
  elif [ $DPDK_DRIVER = "vfio-pci" ]
  then
    echo "Using vfio-pci driver"
    lsmod |grep -w "^uio" >/dev/null 2>&1 || modprobe vfio-pci
    port=0
    while [ $port -lt $NUMB_OF_PCI_PORTS ]
    do
        $RTE_BIND -u ${pci_port_type[$port]}
        $RTE_BIND -b vfio-pci ${pci_port_type[$port]}
        port=`expr $port + 1`
    done
    $RTE_BIND --status
  else
    echo "This driver is not supported by validium"
  fi
else
    echo "The number of ports is greater than real number of ports"
fi
