#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description:
#    Need to install some dependencies firstly, before install crucio (dpdk,PROX/DATS)
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

sudo yum -y -x 'kernel*' update
sudo yum install yum-utils wget vim tcpdump screen -y
sudo yum -y install sed gawk grep wget tar gzip bzip2 unzip coreutils pciutils psmisc
sudo yum -y install gcc make git autoconf automake libtool python perl patch
sudo yum install -y net-tools
yum -y groupinstall "Development Tools"
yum -y install bridge-utils
# Install dependencies for dpdk
sudo  yum -y install kernel-devel kernel-devel-$(uname -r)
# Install dependencies for PROX
sudo yum -y install ncurses-devel libpcap-devel libedit-devel lua-devel
# Install dependencies for OVS (for SUT only)
sudo yum -y install python-devel openssl-devel kernel-debug-devel graphviz
# Install dependencies for QEMU and VMs
sudo yum -y install glib2-devel numactl-devel libvirt bridge-utils
# Install dependencies for  DATS
sudo yum -y install gnuplot python-docutils
#For installing rst2pdf
#01. Install PIP (cloudify already installed pip so we don't need do it again)
#wget -r --no-parent -A 'epel-release-*.rpm' http://dl.fedoraproject.org/pub/epel/7/x86_64/e/ 
#sudo rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-*.rpm
#sudo yum install -y python-pip
#02. Install rst2pdf dependencies
sudo yum install -y libjpeg-devel zlib-devel python-devel setuptools
#03. Install rst2pdf
sudo pip install rst2pdf
