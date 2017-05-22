#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

# Machine's information
export USERNAME=root                                        #validium_baremetal_user_1
export PASSWD=validium2016                                  #validium_baremetal_password_1
export TG_IP=10.64.0.105
export SUT_IP=10.64.0.106                                   #validium_baremetal_ip_1
export MANAGER_IP=10.64.0.101
# Software packages's versions
export DPDK_VER=2.2.0                                       #DPDK_VER
export PROX_VER=85806f9431cc2d70ad5a82d3d07eff78af3486ea    #PROX_VER
export DATS_VER=f1da5139b2c1a9134abfb6f304c980cd445c9a38
export OvS_VER=2.4.0                                        #OvS_VER
# OvS dpdk arguments
# export OVS_DPDK_ARGS="-c 0x1 -n 4 --socket-mem 4096,0"
# export OVS_PMD_CPU_MASK=1E
# export OVS_MAX_IDLE=30000
# export OVS_LOG_FILE=/root/white/virt/ovs.log
# PCI type and number of PCI ports
export PCI_TYPE=82599ES                                     #PCI_TYPE
export NUMB_OF_PCI_PORTS=4                                  #NUMB_OF_PCI_PORTS
# The type of dpdk driver
export DPDK_DRIVER=igb_uio                                  #DPDK_DRIVER
# Grub configurations
# Isolate cores in grub configuration file.
export FIRST_ISO_CORE=1
export LAST_ISO_CORE=71
export DEFAULT_HUGEPAGESZ=1G
export HUGEPAGESZ=1G
export HUGEPAGES=56
export IDLE_MAX_CSTATE=0
export P_MAX_CSTATE=0
# Some environment's variables
export RTE_SDK=/opt/crucio/dpdk
export RTE_TARGET=x86_64-native-linuxapp-gcc
export RTE_BIND=$RTE_SDK/tools/dpdk_nic_bind.py
# Setup management bridge and interface so that connecting VM to internet
# Note that br1 is external dridge, br0 is internal interface \
# which was not exposed to user (br0 is ovs bridge)
export MGMT_BR=br1
export MGMT_IF=`route | grep '^default' | grep -o '[^ ]*$'`
# Qemu version
export QEMU_VER=2.3.1                                      #QEMU_VER
# VM's parameters
export VM1_IP=10.64.0.190
export VM_NETMASK=255.255.255.0
export GW=10.64.0.1

