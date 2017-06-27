#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

n1=tap01
n2=tap02
n3=tap03
n4=tap04
sudo ip link delete $n1
sudo ip link delete $n2
sudo ip link delete $n3
sudo ip link delete $n4
pkill -9 qemu
