#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description:
#    Get server's IP to know that it is TG or SUT
#    Only apply patch for dpdk if dpdk version is 2.2.0 and server is SUT
#    Install dpdk on both SUT and TG
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

path="$(pwd)"
#source $path/env.sh

# Get server's IP
NET=$(route | grep '^default' | grep -o '[^ ]*$')
ipaddr=$(ifconfig $NET  | grep -ie "inet" | grep -ioEe "([0-9]+\.){3}[0-9]+")
ipaddr=($ipaddr)
IP=${ipaddr[0]}

# Get dpdk with the expected version
cd  /root/crucio
rm -rf dpdk*
wget http://www.dpdk.org/browse/dpdk/snapshot/dpdk-$DPDK_VER.tar.gz
tar -zxf dpdk-$DPDK_VER.tar.gz
ln -snf dpdk-$DPDK_VER dpdk

# Apply some changes
if [ $IP = $SUT_IP ]
then
cd $RTE_SDK
#=================================================================
if [ $DPDK_VER = 2.2.0 ]
then
# Apply patch for dpdk 2.2.0
echo "Applying patch for Bng-QoS test"
# cd /root/dpdk
patch -p1 < /root/pre-config/dats-patchs/common-patchs/patch/dpdk/vhost-ignore-cleared-virtqueue.patch
cat > config/defconfig_$RTE_TARGET << EOL
#include "common_linuxapp"

# OVS-specific customization
CONFIG_RTE_BUILD_COMBINE_LIBS=y
CONFIG_RTE_LIBRTE_VHOST=y
CONFIG_RTE_LIBRTE_VHOST_USER=y
#
CONFIG_RTE_ARCH_64=y
CONFIG_RTE_TOOLCHAIN="gcc"
CONFIG_RTE_TOOLCHAIN_GCC=y
CONFIG_RTE_MACHINE="native"
CONFIG_RTE_ARCH="x86_64"
CONFIG_RTE_ARCH_X86_64=y
EOL
fi
#=================================================================
else
echo "This is tester, do nothing"
fi

# Install dpdk on both SUT and TG
cd $RTE_SDK
make install T=$RTE_TARGET
