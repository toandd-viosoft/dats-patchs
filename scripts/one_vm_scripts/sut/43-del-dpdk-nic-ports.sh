#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

ovs-vsctl --if-exists del-port br0 dpdk0
ovs-vsctl --if-exists del-port br0 dpdk1
ovs-vsctl --if-exists del-port br0 dpdk2
ovs-vsctl --if-exists del-port br0 dpdk3
