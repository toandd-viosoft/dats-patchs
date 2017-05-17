#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

cd ~/white/virt/
rm -rf qemu*
wget http://wiki.qemu-project.org/download/qemu-$QEMU_VER.tar.bz2
tar -jxf qemu-$QEMU_VER.tar.bz2
ln -snf qemu-$QEMU_VER qemu
cd qemu/
./configure --target-list=x86_64-softmmu --disable-werror
make
make install
cd -
