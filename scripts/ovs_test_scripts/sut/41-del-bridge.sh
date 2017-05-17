#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

ovs-vsctl --if-exists del-br br0
rm -f $OVS_SOCKDIR/p{0,1,2,3}
