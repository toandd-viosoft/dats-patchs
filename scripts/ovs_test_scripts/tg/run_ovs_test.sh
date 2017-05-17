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

cd $path && ./preparing_dats_directory.sh
cd $path && ./creating_dats_cfg_for_ovs.sh
cd /root/crucio/DATS
./dats.py -f ovs-dpdk-host.cfg -d tests-ovs-dpdk -r report-ovs-base
