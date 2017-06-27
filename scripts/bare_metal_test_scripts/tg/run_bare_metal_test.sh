#!/bin/bash

#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.

path="$(pwd)"

cd $path && ./creating_dats_cfg_for_bare-metal.sh

cd /root/crucio/DATS
python dats.py -f dats.cfg
