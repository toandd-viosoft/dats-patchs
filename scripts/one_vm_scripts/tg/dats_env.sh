#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

path="$(pwd)"
source $path/../../env.sh

# DATS's configuration
USER_NAME=$USERNAME
PASS_WD=$PASSWD
TESTER_IP_ADDRESS=$TG_IP
SUT_IP_ADDRESS=$SUT_IP
PKT_SIZES=64
TOLERATED_LOSS=0.001
LOGING_LEVEL=DEBUG
LOG_FILE=dats.log
LOG_OVERWRITE=1
PROX_DIR=/root/crucio/PROX
CRUCIO_RTE_SDK=$RTE_SDK
CRUCIO_RTE_TARGET=$RTE_TARGET
VM_PROX_DIR=/root/PROX
VM_RTE_SDK=/root/dpdk
