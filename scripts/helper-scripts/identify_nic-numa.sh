#!/bin/bash

#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.

# Make sure that you don't have any virtual interface in your machines
echo "Make sure that you don't have any virtual interface in your machines except lo"
nic_array=`ifconfig -a | expand | cut -c1-8 | sort | uniq -u | awk -F: '{print $1;}' | grep -Fvx -e lo`
nic_array=($nic_array)
# Counting the number of network nic cards
numb_nics=${#nic_array[@]}
echo "Device names	Numa Nodes"
i=0
while [ $i -lt $numb_nics ]
do 
echo -n "${nic_array[$i]}	" && cat  /sys/class/net/${nic_array[$i]}/device/numa_node
i=`expr $i + 1`
done
