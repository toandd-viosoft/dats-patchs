#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

virsh net-autostart default --disable
virsh net-destroy default
#virsh iface-unbridge $MGMT_BR
# Determine management interface name
# If this fails, manually set MGMT_IF
[ -z "$MGMT_IF" ] && MGMT_IF=$($RTE_BIND --status |sed -n -e '/\*Active\*/ s/^.* if=\([^ ]*\) .*$/\1/p')
[ $(echo "$MGMT_IF" |wc -w) -eq 1 ] && echo "OK, management interface is: $MGMT_IF" || echo "Please manually set MGMT_IF"

# Move DNS configuration from management interface to network
sed -n -e '/^DNS/ p' /etc/sysconfig/network-scripts/ifcfg-$MGMT_IF >>/etc/sysconfig/network
sed -i -e '/^DNS/ d' /etc/sysconfig/network-scripts/ifcfg-$MGMT_IF
sed -n -e '/^DOMAIN/ p' /etc/sysconfig/network-scripts/ifcfg-$MGMT_IF >>/etc/sysconfig/network
sed -i -e '/^DOMAIN/ d' /etc/sysconfig/network-scripts/ifcfg-$MGMT_IF

# Create management bridge with management interface attached
# Immediately restart network service to avoid losing remote connection
# Note: It might take one minute for network service to restart
virsh iface-unbridge $MGMT_BR
virsh iface-bridge $MGMT_IF $MGMT_BR ; service network restart
