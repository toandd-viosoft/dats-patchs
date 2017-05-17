#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

./41-del-bridge.sh
./42-add-bridge.sh
./43-del-dpdk-nic-ports.sh
./44-add-dpdk-nic-ports.sh
./_45-del-vhost-vm-ports.sh
./_46-add-vhost-vm-ports.sh
./48-show-bridge.sh
