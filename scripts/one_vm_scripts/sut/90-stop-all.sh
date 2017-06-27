#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

./69-stop-vm.sh
./39-stop-ovs-vswitchd.sh
./29-stop-ovsdb-server.sh
true
