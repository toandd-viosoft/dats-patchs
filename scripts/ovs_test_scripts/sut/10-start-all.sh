#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

source ../../env.sh
../../00-after-boot.sh
./20-start-ovsdb-server.sh
./30-start-ovs-vswitchd.sh
./40-setup-bridge.sh
./50-setup-flows.sh
