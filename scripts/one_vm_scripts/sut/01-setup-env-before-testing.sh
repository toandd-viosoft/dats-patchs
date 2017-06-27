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
echo $path
cd $path/../.. && source ./env.sh

DIRECTORY=~/white/virt
if [ -d "$DIRECTORY" ]; then
  echo "$DIRECTORY already existed"
else
  mkdir -p $DIRECTORY
fi
cd $path/../.. && ./00-after-boot.sh

cd $path
./02_get-build-install_qemu.sh
./03-setup-virtualization-network.sh
#./04-restart-machine-to-verify.sh
./05-verify-mgmtif-attached.sh
./06-create-VM_hard-disk_helper-scripts.sh
#./07-start-VM-with-iso-file.sh
