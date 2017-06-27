#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: 
#    Automatically get active network interface name, which can connect to internet
#    Automatically get active IP,netmask,gateway of that interface
#    Create a configuration file to set static IP for network interface
#    Enable network service and disable network-manager service, We control network by ourself
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

# Get network interface name, get IP,netmask,gateway of that interface
NET=$(route | grep '^default' | grep -o '[^ ]*$')
ipaddr=$(ifconfig $NET  | grep -ie "inet" | grep -ioEe "([0-9]+\.){3}[0-9]+")
ipaddr=($ipaddr)
IP=${ipaddr[0]}
PREF=$(ip add show $NET | grep -ioEe "([0-9]+\.){3}[0-9]+/[0-9]+" | grep -iEoe "[0-9]+$")
GW=$(ip route show | grep default | grep -oiEe "([0-9]+\.){3}[0-9]+")

# Create network static IP allocation
cat > /etc/sysconfig/network-scripts/ifcfg-$NET << EOL
DEVICE=$NET
NAME=$NET
BOOTPROTO=static
IPADDR=$IP
PREFIX=$PREF
GATEWAY=$GW
ONBOOT=yes
DNS1=8.8.8.8
DNS2=8.8.4.4
EOL

# Disable network manager
sudo systemctl disable NetworkManager.service
sudo systemctl disable firewalld.service
sudo chkconfig network on
sudo systemctl restart network.service
sudo systemctl stop NetworkManager.service
