#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description:
#    Resetting state for systems after rebooting
#    Checking system is SUT or TG
#    Getting PROX
#    Applying patch to PROX if PROX's version is 85806f9431cc2d70ad5a82d3d07eff78af3486ea
#    Getting DATS
#    Applying patch to DATS if DATS's version is f1da5139b2c1a9134abfb6f304c980cd445c9a38
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

#Getting machine's IP address
NET=$(route | grep '^default' | grep -o '[^ ]*$')
ipaddr=$(ifconfig $NET  | grep -ie "inet" | grep -ioEe "([0-9]+\.){3}[0-9]+")
ipaddr=($ipaddr)
IP=${ipaddr[0]}
# Resetting state for the system
echo 0 > /opt/flag.txt
#Getting PROX's source code
cd /opt/crucio
rm -rf PROX*
git clone https://github.com/nvf-crucio/PROX
cd PROX
git checkout $PROX_VER
if [ $PROX_VER = 85806f9431cc2d70ad5a82d3d07eff78af3486ea ]
then
    cd /opt/dats-patchs
    git checkout master
    patch -p1 < /opt/dats-patchs/common-patchs/patch/prox/more-rxtx-desc-and-larger-mbuf-cache.patch
    cd -
fi
# Building PROX
make

if [ $IP = $TG_IP ]
then
    echo "Getting DATS for TG"
    # Get DATS
    cd /opt/crucio
    rm -rf DATS*
    git clone https://github.com/nvf-crucio/DATS
    cd DATS
    git checkout $DATS_VER
    if [ $DATS_VER = f1da5139b2c1a9134abfb6f304c980cd445c9a38 ]
    then
        cd ../
        patch -d DATS/tests/ -p1 < /root/pre-config/dats-patchs/common-patchs/patch/dats/adjust-mempool-for-more-rxtx-desc.patch
        # Gettign new patchs for DATS
        cd DATS/
        mv tests/prox-configs/ tests/prox-configs.old/
        rm -rf dats-patchs/
        git clone https://github.com/toandd-viosoft/dats-patchs.git
        cp -r dats-patchs/baremetal-patchs/prox-configs/ tests/
        chmod +x dats.py
    fi
else
    echo "This is SUT, don't install DATS"
fi
