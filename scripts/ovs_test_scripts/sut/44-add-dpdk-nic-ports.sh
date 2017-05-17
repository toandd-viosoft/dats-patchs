#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk0 type=dpdk
ovs-vsctl add-port br0 dpdk1 -- set Interface dpdk1 type=dpdk
ovs-vsctl add-port br0 dpdk2 -- set Interface dpdk2 type=dpdk
ovs-vsctl add-port br0 dpdk3 -- set Interface dpdk3 type=dpdk
