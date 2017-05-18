#!/bin/sh
##############################################################################
# Copyright (c) 2015 Ericsson AB and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# installs required packages
# must be run from inside the image (either chrooted or running)
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -ex
# Get some VMs's parameters
# source ./vm-args.sh

if [ $# -eq 1 ]; then
    nameserver_ip=$1

    # /etc/resolv.conf is a symbolic link to /run, restore at end
    /bin/rm -f /etc/resolv.conf
    #/usr/bin/touch /etc/resolv.conf
    echo "nameserver $nameserver_ip" > /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf
fi

# iperf3 only available for wily in backports
#grep wily /etc/apt/sources.list && \
#    echo "deb http://archive.ubuntu.com/ubuntu/ wily-backports main restricted universe multiverse" >> /etc/apt/sources.list

# Workaround for building on CentOS (apt-get is not working with http sources)
# sed -i 's/http/ftp/' /etc/apt/sources.list

# Force apt to use ipv4 due to build problems on LF POD.
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

sed -i '/^.*GRUB_CMDLINE_LINUX=.*$/d' /etc/default/grub
echo "GRUB_CMDLINE_LINUX=\"resume=/dev/sda1 default_hugepagesz=$VM_DEF_HUG hugepagesz=$VM_HUGZ hugepages=$VM_HUG isolcpus=$VM_ISOL_CPU rcu_nocbs=$VM_RCU_NOCBS intel_idle.max_cstate=$VM_IDLE_MAX_CSTATE processor.max_cstate=$VM_P_MAX_CSTATE\"" >> /etc/default/grub
#echo 'vm.nr_hugepages=8912' >> /etc/sysctl.conf
#echo 'huge /mnt/huge hugetlbfs defaults 0 0' >> vi /etc/fstab

/bin/mkdir /mnt/huge
/bin/chmod 777 /mnt/huge

for i in {1..2}
do
    /usr/bin/touch /etc/network/interfaces.d/eth$i.cfg
    /bin/chmod 777 /etc/network/interfaces.d/eth$i.cfg
    echo "auto eth$i" >> /etc/network/interfaces.d/eth$i.cfg
    echo "iface eth$i inet dhcp" >> /etc/network/interfaces.d/eth$i.cfg
done

# this needs for checking dpdk status, adding interfaces to dpdk, bind, unbind etc..

# Add hostname to /etc/hosts.
# Allow console access via pwd
/usr/bin/touch /etc/cloud/cloud.cfg.d/10_etc_hosts.cfg

echo "manage_etc_hosts: True" > /etc/cloud/cloud.cfg.d/10_etc_hosts.cfg
echo "password: validium2016" >> /etc/cloud/cloud.cfg.d/10_etc_hosts.cfg
echo "chpasswd: { expire: False }" >> /etc/cloud/cloud.cfg.d/10_etc_hosts.cfg
echo "ssh_pwauth: True" >> /etc/cloud/cloud.cfg.d/10_etc_hosts.cfg


linuxheadersversion=`echo ls boot/vmlinuz* | cut -d- -f2-`
sudo locale-gen "en_US.UTF-8"
sudo dpkg-reconfigure locales
apt-get update
apt-get install -y \
    fio \
    gcc \
    git \
    expect\
    net-tools\
    linux-tools-common \
    linux-tools-generic \
    lmbench \
    make \
    netperf \
    patch \
    perl \
    rt-tests \
    stress \
    sysstat \
    linux-headers-$linuxheadersversion \
    libpcap-dev \
    lua5.2

ifconfig -a

echo "$USERNAME:$PASSWD"  | chpasswd
cat /etc/network/interfaces
echo "auto lo eth0" > /etc/network/interfaces
echo "iface lo inet static" >> /etc/network/interfaces
echo "auto eth0" >> /etc/network/interfaces
echo "iface eth0 inet static" >> /etc/network/interfaces
echo "address $VM1_IP" >> /etc/network/interfaces
echo "netmask $VM_NETMASK" >> /etc/network/interfaces
echo "gatway $GW" >> /etc/network/interfaces
cat /etc/network/interfaces

# SSH setting
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
# Generate SSH key pair
cd /root
cat - >genkey.sh <<'EOF'
#!/usr/bin/expect
spawn ssh-keygen
expect "Enter file in which to save the key (/root/.ssh/id_rsa): "
send -- "\r"
expect "Enter passphrase (empty for no passphrase): "
send -- "\r"
expect "Enter same passphrase again: "
send -- "\r"
sleep 2
EOF
chmod +x genkey.sh
#./genkey.sh
# The scripts with 3 parameters
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
#Then restart SSH:
service ssh restart
# SELINUX is disabled by Ubuntu default
# Disable firewall, irqbalance and randomize memory
sudo ufw disable
sed -i 's/ENABLED="1"/ENABLED="0"/g' /etc/default/irqbalance
echo "kernel.randomize_va_space = 0" >>  /etc/sysctl.conf
# The Linux kernel is updated to 4.4.x because it’s NTT Docomo requirement (will be supported later)
#sudo apt-get install linux-image-generic-lts-xenial
#sudo apt-get install linux-headers-generic-lts-xenial
# use bash shell as default shell
ln -sf /bin/bash /bin/sh
sudo apt-get -y install yum-utils wget vim tcpdump screen
sudo apt-get -y install sed gawk grep wget tar gzip bzip2 unzip coreutils pciutils psmisc
sudo apt-get -y install gcc make git autoconf automake libtool python perl patch
sudo apt-get -y install net-tools
sudo apt-get -y install grub-common
ln -s /usr/bin/env /bin/env
apt-get -y install liblua5.2-dev
apt-get -y install libpcap-dev
apt-get -y install libncurses5-dev libncursesw5-dev
apt-get -y install libedit-dev
sudo sh -c 'echo "deb http://archive.canonical.com/ubuntu/ vivid partner" >> /etc/apt/sources.list.d/canonical_partner.list'
apt-get -y update
# Cannot install two packages below, don't know the reason, So will install it later when VMs booted
# apt-get -y install linux-generic linux-headers-generic
# apt-get -y install linux-generic linux-headers-generic
# Setup working environment variables
export RTE_SDK=/root/dpdk
export RTE_TARGET=x86_64-native-linuxapp-gcc
export RTE_BIND=$RTE_SDK/tools/dpdk_nic_bind.py

cd /root
mkdir -p ~/white
# Get patch
git clone https://github.com/toandd-viosoft/dats-patchs.git
cp -r dats-patchs/common-patchs/patch ~/white
# Get dpdk follow version
wget http://www.dpdk.org/browse/dpdk/snapshot/dpdk-$DPDK_VER.tar.gz
tar -zxf dpdk-$DPDK_VER.tar.gz
ln -snf dpdk-$DPDK_VER dpdk
if [ $DPDK_VER = 2.2.0 ]
then
# Apply patch for dpdk 2.2.0
echo "Applying patch for Bng-QoS test"
cd /root/dpdk
patch -p1 < /root/white/patch/dpdk/virtio-always-run-mbuf-allocation-loop.patch
cat > config/defconfig_$RTE_TARGET << EOL
#include "common_linuxapp"

# OVS-specific customization
CONFIG_RTE_BUILD_COMBINE_LIBS=y
CONFIG_RTE_LIBRTE_VHOST=y
CONFIG_RTE_LIBRTE_VHOST_USER=y
#
CONFIG_RTE_ARCH_64=y
CONFIG_RTE_TOOLCHAIN="gcc"
CONFIG_RTE_TOOLCHAIN_GCC=y
CONFIG_RTE_MACHINE="native"
CONFIG_RTE_ARCH="x86_64"
CONFIG_RTE_ARCH_X86_64=y
EOL
fi
#cd $RTE_SDK
#make install T=$RTE_TARGET

# Install PROX (PROX v031)
cd /root
git clone https://github.com/nvf-crucio/PROX
cd PROX
git checkout $PROX_VER
if [ $PROX_VER = 85806f9431cc2d70ad5a82d3d07eff78af3486ea ]
then
echo "Applying patch for BNG-QoS test"
cp /root/white/patch/prox/* ../
patch -p1 < ../more-rxtx-desc-and-larger-mbuf-cache.patch
fi
# Create ENV setup script, meant to be sourced rather than executed
cd /root/white
cat - >env.sh <<'EOF'
export RTE_SDK=/root/dpdk
export RTE_TARGET=x86_64-native-linuxapp-gcc
export RTE_BIND=$RTE_SDK/tools/dpdk_nic_bind.py
cd ~
EOF

cat - >ports-to-bind <<EOF
00:04.0
00:05.0
00:06.0
00:07.0
EOF

cat - >00-after-boot.sh <<'EOF'
#!/bin/sh
lsmod |grep -w "^uio" >/dev/null 2>&1 || modprobe uio
lsmod |grep -w "^igb_uio" >/dev/null 2>&1 || insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko
bound=$($RTE_BIND --status |sed -n -e '/drv=igb_uio/ s/^\([[:xdigit:]:.]*\).*$/\1/p')
[ -z "$bound" ] || $RTE_BIND -u $bound
$RTE_BIND -b igb_uio $(cat ports-to-bind)
$RTE_BIND --status
EOF

cat - >01-mount-hugepage.sh <<'EOF'
#!/bin/sh
mkdir -p /mnt/huge
umount `awk '/hugetlbfs/ { print $2 }' /proc/mounts` >/dev/null 2>&1
echo 4096 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
#echo 512 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
#echo 1 > /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages
#echo 1 > /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
mount -t hugetlbfs nodev /mnt/huge
EOF

chmod +x 00-after-boot.sh
chmod +x 01-mount-hugepage.sh

# Run all after VM booting
cd /root
cat - >run-all-after-vm-booting.sh <<'EOF'
#!/bin/sh
apt-get update
EOF

chmod +x run-all-after-vm-booting.sh
#==========================================================================
echo "route add default gw $GW" >> /root/run-all-after-vm-booting.sh
echo "apt-get -y install linux-generic linux-headers-generic --force-yes" >> /root/run-all-after-vm-booting.sh
echo "source ~/white/env.sh" >> /root/run-all-after-vm-booting.sh
echo "cd $RTE_SDK" >> /root/run-all-after-vm-booting.sh
echo "make install T=$RTE_TARGET" >> /root/run-all-after-vm-booting.sh
echo "cd /root/PROX" >> /root/run-all-after-vm-booting.sh
echo "make" >> /root/run-all-after-vm-booting.sh
echo "cd ~/white" >> /root/run-all-after-vm-booting.sh
echo "./00-after-boot.sh" >> /root/run-all-after-vm-booting.sh
echo "./01-mount-hugepage.sh" >> /root/run-all-after-vm-booting.sh
#==========================================================================
#git clone https://github.com/beefyamoeba5/ramspeed.git /opt/tempT/RAMspeed
#cd /opt/tempT/RAMspeed/ramspeed-2.6.0
#/bin/mkdir temp
#bash build.sh

#git clone https://github.com/beefyamoeba5/cachestat.git /opt/tempT/Cachestat

# restore symlink
# /bin/ln -sf /run/resolvconf/resolv.conf /etc/resolv.conf
