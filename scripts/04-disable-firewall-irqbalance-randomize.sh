#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description:
#    Disable some services which can cause poor performance in crucio test
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

sudo service iptables save
sudo systemctl stop firewalld
sudo systemctl disable  firewalld
sudo systemctl disable irqbalance.service
echo 0 > /proc/sys/kernel/randomize_va_space
