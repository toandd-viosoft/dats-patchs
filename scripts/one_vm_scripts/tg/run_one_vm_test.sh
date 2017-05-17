#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

path="$(pwd)"
source ../../env.sh
../../00-after-boot.sh
cd $path && ./01-copy-ssh-key-to-vm.sh
cd $path && ./02-setup-env.sh
cd $path && ./creating_dats_cfg_for_one_vm.sh
cd /root/crucio/DATS
./dats.py -f ovs-dpdk-host_vm.cfg -d tests-virt -r report-ovs-1vm
