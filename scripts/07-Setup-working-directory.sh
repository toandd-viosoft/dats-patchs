#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: 
#    Create a directory as a working directory
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

[ -d /root/crucio ] && rm -rf /root/crucio
mkdir -p /root/crucio
cd /root/crucio
#export RTE_SDK=/root/crucio/dpdk
#export RTE_TARGET=x86_64-native-linuxapp-gcc
#export RTE_BIND=$RTE_SDK/tools/dpdk_nic_bind.py
#echo "export RTE_SDK=/root/crucio/dpdk" >> /root/.bashrc
#echo "export RTE_TARGET=x86_64-native-linuxapp-gcc" >> /root/.bashrc
#echo "export RTE_BIND=$RTE_SDK/tools/dpdk_nic_bind.py" >> /root/.bashrc
#. /root/.bashrc
