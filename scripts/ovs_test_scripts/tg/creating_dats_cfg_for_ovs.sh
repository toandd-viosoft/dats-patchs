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
source $path/dats_env.sh

cd /root/crucio/DATS
cat > ovs-dpdk-host.cfg << EOF
;
; Dataplane Automated Testing System
;
; Copyright (c) 2015-2016, Intel Corporation.
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
;
;   * Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
;   * Redistributions in binary form must reproduce the above copyright
;     notice, this list of conditions and the following disclaimer in
;     the documentation and/or other materials provided with the
;     distribution.
;   * Neither the name of Intel Corporation nor the names of its
;     contributors may be used to endorse or promote products derived
;     from this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
[general]
; Which packet sizes to use when testing. Tests are run for each
; packet size in turn.
; Default value: 64,128,256,512,1024,1280,1518
pkt_sizes=$PKT_SIZES

; Which tests to run. This can be overridden by specifying test names
; on the command line.
; Default value: all tests in the tests/ directory.
; tests=$TESTS

; This setting specifies the percentage of packets sent by the Tester that can
; be tolerated to be lost, instead of being properly forwarded by the SUT.
; Note: Although the % symbol must not be provided here, the supplied value is a
; percentage: a value of 0.001 means 0.001%, that is 1 packet is tolerated to be
; lost out of 100,000 packets sent by the Tester to the SUT.
; Default value: 0.0
tolerated_loss = $TOLERATED_LOSS


[logging]
; Valid values are DEBUG, INFO, WARNING, ERROR, CRITICAL.
level=$LOGING_LEVEL

; Default value: dats.log
;file=$LOG_FILE

; See https://docs.python.org/2/library/logging.html#logging.Formatter for an
; explanation on the log format and datefmt and
; https://docs.python.org/2/library/logging.html#logrecord-attributes for a list
; of format attributes.
;format=%(asctime)-15s %(levelname)-8s %(filename)20s:%(lineno)-3d %(message)s
;datefmt=

; 0 to append to logfile if it exists already, 1 to overwrite.
;overwrite=$LOG_OVERWRITE


[tester]
ip=$TESTER_IP_ADDRESS
user=$USER_NAME

; Default value: /root/dpdk
rte_sdk=$CRUCIO_RTE_SDK

; Default value: x86_64-native-linuxapp-gcc
;rte_target=$CRUCIO_RTE_TARGET

; Default value: /root/prox
prox_dir=$PROX_DIR


[sut]
ip=$SUT_IP_ADDRESS
user=$USER_NAME

; Default value: /root/dpdk
rte_sdk=$CRUCIO_RTE_SDK

; Default value: x86_64-native-linuxapp-gcc
;rte_target=$CRUCIO_RTE_TARGET

; Default value: /root/prox
prox_dir=/none
EOF
