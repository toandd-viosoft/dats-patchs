#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

set -x

source ../../env.sh
source ./vm-args.sh
../../00-after-boot.sh
[ -f /home/crucio-trusty-server.qcow2 ] && rm -rf /home/crucio-trusty-server.qcow2
./del_tap_if_exists.sh
./90-stop-all.sh
./01-setup-env-before-testing.sh
# Save time deploy server when run the second time
#./crucio-ubuntu-img-dpdk-modify ubuntu-server-cloudimg-dpdk-modify.sh
./20-start-ovsdb-server.sh
./30-start-ovs-vswitchd.sh
./40-setup-bridge.sh
./50-setup-flows.sh
# Remove old know_host
sed -i "/^$VM1_IP.*$/d" /root/.ssh/known_hosts
./60-start-vm.sh
