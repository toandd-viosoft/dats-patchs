#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

source ./ovs-dpdk-args.sh
cmd="ovs-vswitchd"
cmd="$cmd --dpdk -vhost_sock_dir $OVS_SOCKDIR $OVS_DPDK_ARGS --"
cmd="$cmd unix:$OVS_DBSOCK"
cmd="$cmd --pidfile --detach"
cmd="$cmd --log-file=$OVS_LOG_FILE"
$cmd
ovs-vsctl set Open_vSwitch . other_config:pmd-cpu-mask=$OVS_PMD_CPU_MASK
ovs-vsctl set Open_vSwitch . other_config:max-idle=$OVS_MAX_IDLE
