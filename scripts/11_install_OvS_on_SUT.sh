#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: 
#    Checking if system is SUT or TG, installing ovs only on SUT
#    Getting ovs and ovs patch
#    Applying patch if ovs's version is 2.4.0
#    Building and installing ovs on SUT
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

path="$(pwd)"
source $path/env.sh
#Getting machine's IP address
NET=$(route | grep '^default' | grep -o '[^ ]*$')
ipaddr=$(ifconfig $NET  | grep -ie "inet" | grep -ioEe "([0-9]+\.){3}[0-9]+")
ipaddr=($ipaddr)
IP=${ipaddr[0]}

# Checking if this machine is SUT, install OvS dpdk on it
if [ $IP = $SUT_IP ]
then
    echo " ... Installing OvS for SUT machine"
    export DPDK_DIR=$RTE_SDK
    export DPDK_BUILD=$RTE_SDK/$RTE_TARGET
    export OVS_SOCKDIR=/usr/local/var/run/openvswitch
    export OVS_DBSOCK=$OVS_SOCKDIR/db.sock

    echo "export DPDK_DIR=$RTE_SDK" >> /root/.bashrc
    echo "export DPDK_BUILD=$RTE_SDK/$RTE_TARGET" >> /root/.bashrc
    echo "export OVS_SOCKDIR=/usr/local/var/run/openvswitch" >> /root/.bashrc
    echo "export OVS_DBSOCK=$OVS_SOCKDIR/db.sock" >> /root/.bashrc

    cd /opt/crucio
    #Get OVS patch from GitHub
    mkdir -p ovs-dpdk/patch
    cd ovs-dpdk/patch
    rm -rf *
    wget https://github.com/openvswitch/ovs/commit/46ab6540af451ecacaecd87cde86264e928a56d8.patch
    cd -

    #Get OVS
    rm -rf openvswitch* ovs/
    wget http://openvswitch.org/releases/openvswitch-$OvS_VER.tar.gz
    tar -zxf openvswitch-$OvS_VER.tar.gz
    ln -snf openvswitch-$OvS_VER ovs
    cd ovs/

    if [ $OvS_VER = "2.4.0" ]
    then
        #Adjust OVS to new name of DPDK 2.2.0 combined library
        sed -i -e 's/DPDK_LIB="-lintel_dpdk"/DPDK_LIB="-ldpdk"/' acinclude.m4

        #Fix MBUF_SIZE macro, based on https://github.com/openvswitch/ovs/commit/18f777b
        l0='^#define MBUF_SIZE(mtu)'
        l1='#define MBUF_SIZE_MTU(mtu) (MTU_TO_MAX_LEN(mtu) + sizeof(struct dp_packet) + RTE_PKTMBUF_HEADROOM)'
        l2='#define MBUF_SIZE_DRIVER (2048 + sizeof(struct rte_mbuf) + RTE_PKTMBUF_HEADROOM)'
        l3='#define MBUF_SIZE(mtu) MAX(MBUF_SIZE_MTU(mtu), MBUF_SIZE_DRIVER)'
        sed -i -e "/$l0/{N;s/^.*\$/$l1\\n$l2\\n$l3/}" lib/netdev-dpdk.c

        #Fix destroy_device() function, using OVS patch from https://github.com/openvswitch/ovs/commit/46ab654
        patch -p1 < /opt/crucio/ovs-dpdk/patch/46ab6540af451ecacaecd87cde86264e928a56d8.patch
    fi

    #Build OVS
    ./boot.sh
    ./configure --with-dpdk=$DPDK_BUILD CFLAGS="-g -O3 -march=native"
    make CFLAGS="-g -O3 -march=native"
    make install
    cd -
else
    echo "This isn't SUT, don't install OvS"
fi
