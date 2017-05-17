#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

cat flows-to-add | while read pi   po bad ; do
  [ -z "$pi" ] && continue
  [ -z "$po" -o -n "$bad" ] && {
    echo "flows-to-add: wrong format"
    exit 1
  }
  ovs-ofctl add-flow br0 in_port=$pi,action=output:$po || {
    echo "failed to add flow $pi => $po"
    exit 2
  }
done
