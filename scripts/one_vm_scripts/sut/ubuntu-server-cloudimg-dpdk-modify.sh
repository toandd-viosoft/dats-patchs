#!/bin/bash

set -x

# Commandline arguments
PKT_SIZE=$1             # packet size
TESTS=$2                # 01_port_fwd
TOLERATED_LOSS=$3       # 0.0
LOGGING_LEVEL=$4        # INFO
TEST_DURATION=$5        # 5s
#USER=$6                # root
#PASSWORD=$7            # validium2016
PCI_TYPE=$6             # 82599ES
PCI_PORT_NUMBER=$7      # 4
TESTER_IP_ADDRESS=$8    # host ip address
SUT_IP_ADDRESS=$9       # target ip address

DPDK_DRIVER=igb_uio
RTE_SDK=/opt/crucio/dpdk
RTE_TARGET=x86_64-native-linuxapp-gcc
RTE_BIND=$RTE_SDK/tools/dpdk_nic_bind.py
PROX_DIR=/opt/crucio/PROX
USER_NAME=root
PASSWD="validium2016"

create_log_file()
{
cat << EOF > /opt/crucio/result.log
1
EOF
}

change_result()
{
    echo 0 > /opt/crucio/result.log
}

load_modules()
{
    if lsmod | grep "uio" &> /dev/null ; then
    echo "uio module is loaded"
    else
    modprobe uio
    fi

    if lsmod | grep "igb_uio" &> /dev/null ; then
    echo "igb_uio module is loaded"
    else
    insmod $RTE_SDK/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko
    fi

    if lsmod | grep "rte_kni" &> /dev/null ; then
    echo "rte_kni module is loaded"
    else
    insmod $RTE_SDK/x86_64-native-linuxapp-gcc/kmod/rte_kni.ko
    fi
}

change_permissions()
{
    # chmod 777 /sys/bus/pci/drivers/virtio-pci/*
    chmod 777 /sys/bus/pci/drivers/igb_uio/*
}

add_interface_to_dpdk(){
path="$(pwd)"

# Get the name of NIC card, which can connect to internet
NET=$(route | grep '^default' | grep -o '[^ ]*$')
ipaddr=$(ifconfig $NET  | grep -ie "inet" | grep -ioEe "([0-9]+\.){3}[0-9]+")
ipaddr=($ipaddr)
IP=${ipaddr[0]}
#Shouldn't bind the NIC card which was being used to access internet, get its pci address
black_pci=(`ethtool -i $NET | grep bus-info | cut -d':' -f3-5`)
#black_pci=(`$RTE_SDK/tools/dpdk_nic_bind.py -s | grep Active |cut -d':' -f2-4`)
pci_port_type=(`lspci | grep Ether | grep $PCI_TYPE | cut -d' ' -f1`)
num_pci_ports=${#pci_port_type[@]}

#Binding nic cards to dpdk driver, checking whether server has enough pci ports or not
if [ $num_pci_ports -ge $PCI_PORT_NUMBER ]
then
    echo "Using igb_uio driver"
cd $path

  if [ $DPDK_DRIVER = igb_uio ]
  then
    load_modules
    change_permissions
    port=0
    while [ $port -lt $PCI_PORT_NUMBER ]
    do
        $RTE_BIND -u ${pci_port_type[$port]}
        $RTE_BIND -b igb_uio ${pci_port_type[$port]}
        port=`expr $port + 1`
    done
    $RTE_BIND --status
  elif [ $DPDK_DRIVER = "vfio-pci" ]
  then
    echo "Using vfio-pci driver"
    lsmod |grep -w "^uio" >/dev/null 2>&1 || modprobe vfio-pci
    port=0
    while [ $port -lt $PCI_PORT_NUMBER ]
    do
        $RTE_BIND -u ${pci_port_type[$port]}
        $RTE_BIND -b vfio-pci ${pci_port_type[$port]}
        port=`expr $port + 1`
    done
    $RTE_BIND --status
  else
    echo "This driver is not supported by validium"
  fi
else
    echo "The number of ports is greater than real number of ports"
fi
}

create_ssh_copykey()
{
cd /opt
cat - >copy_keygen.sh <<'EOF'
#!/usr/bin/expect
set host [lrange $argv 0 0]
set username [lrange $argv 1 1]
set password [lrange $argv 2 2]
set timeout 10
spawn /usr/bin/ssh-copy-id -i /root/.ssh/id_rsa.pub $username@$host
match_max 100000
expect "*?(yes/no)\?"
send -- "yes\r"
# Look for password prompt
expect {
"*?assword:*" { send -- "$password\r"; send -- "\r"; exp_continue }
eof { exit 1 }
"Now try*\r" { exit 0 }
timeout { exit 1 }
}
exit 0
EOF
chmod +x copy_keygen.sh

}

copy_sshkey_to_sut()
{
cd /opt
[ -f copy_keygen.sh ] || create_ssh_copykey
cd /opt
./copy_keygen.sh $SUT_IP_ADDRESS $USER_NAME $PASSWD
sleep 2

}

create_dats_config_file()
{
cat << EOF > /opt/crucio/DATS/dats.cfg
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
pkt_sizes=$PKT_SIZE

; Which tests to run. This can be overridden by specifying test names
; on the command line.
; Default value: all tests in the tests/ directory.
tests=$TESTS

; This setting specifies the percentage of packets sent by the Tester that can
; be tolerated to be lost, instead of being properly forwarded by the SUT.
; Note: Although the % symbol must not be provided here, the supplied value is a
; percentage: a value of 0.001 means 0.001%, that is 1 packet is tolerated to be
; lost out of 100,000 packets sent by the Tester to the SUT.
; Default value: 0.0
tolerated_loss = $TOLERATED_LOSS


[logging]
; Valid values are DEBUG, INFO, WARNING, ERROR, CRITICAL.
level=$LOGGING_LEVEL

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
rte_sdk=$RTE_SDK

; Default value: x86_64-native-linuxapp-gcc
;rte_target=$RTE_TARGET

; Default value: /root/prox
prox_dir=$PROX_DIR


[sut]
ip=$SUT_IP_ADDRESS
user=$USER_NAME

; Default value: /root/dpdk
rte_sdk=/root/dpdk

; Default value: x86_64-native-linuxapp-gcc
;rte_target=$RTE_TARGET

; Default value: /root/prox
prox_dir=/root/PROX
EOF
}

run_crucio()
{
    blacklist=$(lspci |grep Eth |awk '{print $1}'|head -1)
    cd /opt/crucio/DATS && python dats.py -f dats.cfg -r validium.out
}

convert_result_to_json()
{
    # pip install BeautifulSoup4
    python ~/crucio_convert_to_json.py /opt/crucio/DATS/validium.out/summary.html
}

main()
{
    create_log_file
    create_dats_config_file
    copy_sshkey_to_sut
    add_interface_to_dpdk
    run_crucio
    convert_result_to_json
    change_result
}

main

