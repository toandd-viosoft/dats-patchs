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
# Getting machine's IP address
NET=$(route | grep '^default' | grep -o '[^ ]*$')
ipaddr=$(ifconfig $NET  | grep -ie "inet" | grep -ioEe "([0-9]+\.){3}[0-9]+")
ipaddr=($ipaddr)
IP=${ipaddr[0]}

cd $path/..
# Running all scripts in one step
./07-Setup-working-directory.sh
source $path/../env.sh
#./00-after-boot.sh
cd $path/.. && ./01-ssh-setting.sh
cd $path/.. && ./02-disable-SElinux.sh
cd $path/.. && ./03-Network-setting.sh
cd $path/.. && ./04-disable-firewall-irqbalance-randomize.sh
cd $path/.. && ./05-update-repositories.sh
cd $path/.. && ./06-update-system-common-packages.sh
cd $path/.. && ./08-install-dpdk.sh
cd $path/.. && ./00-after-boot.sh
cd $path/.. && ./09-update-grub_and_reboot-system.sh

# Scripts 10 and 11 will be run after rebooting

#cd $path/.. && ./10_install_PROX_DATS.sh
#cd $path/.. && ./11_install_OvS_on_SUT.sh
