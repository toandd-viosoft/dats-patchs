#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

[ -d ~/white ] || mkdir -p ~/white
cd /root/crucio/DATS/
cp -a tests/ tests-virt
black="eal=-b 0000:00:03.0"
sed -i -e "/^\[eal options\]$/a$black" tests-virt/prox-configs/handle_*
patch -d tests-virt/ -p1 </root/pre-config/dats-patchs/common-patchs/patch/dats/use-single-tx-queue-with-vhost-ports.patch
