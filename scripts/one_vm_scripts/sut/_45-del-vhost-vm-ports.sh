#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

ovs-vsctl --if-exists del-port br0 p0
ovs-vsctl --if-exists del-port br0 p1
ovs-vsctl --if-exists del-port br0 p2
ovs-vsctl --if-exists del-port br0 p3
rm -f $OVS_SOCKDIR/p{0,1,2,3}
