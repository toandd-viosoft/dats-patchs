#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

source ../../env.sh
source ./vm-args.sh
../../00-after-boot.sh
[ -f /home/crucio-trusty-server.qcow2 ] && rm -rf /home/crucio-trusty-server.qcow2
./del_tap_if_exists.sh
./90-stop-all.sh
./01-setup-env-before-testing.sh
./crucio-ubuntu-img-dpdk-modify ubuntu-server-cloudimg-dpdk-modify.sh
./20-start-ovsdb-server.sh
./30-start-ovs-vswitchd.sh
./40-setup-bridge.sh
./50-setup-flows.sh
./60-start-vm.sh
