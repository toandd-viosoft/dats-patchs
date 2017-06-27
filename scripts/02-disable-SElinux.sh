#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: 
#    Be required by crucio tests
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

echo "SELINUX=disabled" > /etc/selinux/config
echo "SELINUXTYPE=targeted" >> /etc/selinux/config
