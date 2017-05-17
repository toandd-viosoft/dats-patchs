#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

cd /root/crucio/DATS
[ -d tests-ovs-dpdk ] && rm -rf tests-ovs-dpdk
mkdir -p tests-ovs-dpdk/prox-configs
cp -a tests/test_01_port_fwd.py tests-ovs-dpdk/test_OVS_port_fwd.py
cp -a tests/prox-configs/gen_all-4.cfg tests-ovs-dpdk/prox-configs/

patch -d tests-ovs-dpdk/ -p1 </root/pre-config/dats-patchs/common-patchs/patch/dats/tests-swsw.patch
