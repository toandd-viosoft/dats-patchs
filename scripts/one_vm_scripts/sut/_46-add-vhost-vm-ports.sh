#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

ovs-vsctl add-port br0 p0 -- set Interface p0 type=dpdkvhostuser
ovs-vsctl add-port br0 p1 -- set Interface p1 type=dpdkvhostuser
ovs-vsctl add-port br0 p2 -- set Interface p2 type=dpdkvhostuser
ovs-vsctl add-port br0 p3 -- set Interface p3 type=dpdkvhostuser
