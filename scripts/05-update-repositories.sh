#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description:
#    After register the system to Redhat, some repos were not enabled by default
#    so need to enable them to install some packages 
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

sudo subscription-manager repos --enable=rhel-7-server-rpms
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
sudo subscription-manager repos --enable=rhel-7-server-optional-rpms
sudo subscription-manager repos --enable=rhel-7-server-rh-common-rpms
