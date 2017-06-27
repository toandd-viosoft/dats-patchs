#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

rm -f /usr/local/etc/openvswitch/conf.db
ovsdb-tool create
cmd="ovsdb-server"
cmd="$cmd --remote=punix:$OVS_DBSOCK"
cmd="$cmd --remote=db:Open_vSwitch,Open_vSwitch,manager_options"
cmd="$cmd --private-key=db:Open_vSwitch,SSL,private_key"
cmd="$cmd --certificate=db:Open_vSwitch,SSL,certificate"
cmd="$cmd --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert"
cmd="$cmd --pidfile --detach"
$cmd
ovs-vsctl --no-wait init
ovs-vsctl show
