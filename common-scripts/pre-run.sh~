#! /bin/bash

sudo yum -y -x 'kernel*' update
#======================================================================
cd /root
rm -rf dpdk*
wget http://fast.dpdk.org/rel/dpdk-2.2.0.tar.xz
tar -xvf dpdk-2.2.0.tar.xz
mv dpdk-2.2.0 dpdk
cd /root/dpdk
export RTE_SDK=/root/dpdk
export RTE_TARGET=x86_64-native-linuxapp-gcc
export RTE_UNBIND=$RTE_SDK/tools/dpdk_nic_bind.py
cd $RTE_SDK && make config T=x86_64-native-linuxapp-gcc
cd $RTE_SDK && make install T=x86_64-native-linuxapp-gcc

sudo modprobe uio
sudo insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko
sudo $RTE_SDK/tools/dpdk_nic_bind.py -u 02:00.0
sudo $RTE_SDK/tools/dpdk_nic_bind.py -u 02:00.1
sudo $RTE_SDK/tools/dpdk_nic_bind.py -u 81:00.0
sudo $RTE_SDK/tools/dpdk_nic_bind.py -u 81:00.1
sudo $RTE_SDK/tools/dpdk_nic_bind.py -b igb_uio 02:00.0
sudo $RTE_SDK/tools/dpdk_nic_bind.py -b igb_uio 02:00.1
sudo $RTE_SDK/tools/dpdk_nic_bind.py -b igb_uio 81:00.0
sudo $RTE_SDK/tools/dpdk_nic_bind.py -b igb_uio 81:00.1
sudo $RTE_SDK/tools/dpdk_nic_bind.py --status
cd /root
#==================Install some packages for PROX========================================
# 
mkdir -p /root/white/install_special_package/
cd /root/white/install_special_package/
wget ftp://mirror.switch.ch/pool/4/mirror/centos/7.2.1511/os/x86_64/Packages/readline-devel-6.2-9.el7.x86_64.rpm
rpm -ivh readline-devel-6.2-9.el7.x86_64.rpm
##Install lua
curl -R -O http://www.lua.org/ftp/lua-5.3.2.tar.gz
tar zxf lua-5.3.2.tar.gz
cd lua-5.3.2
make linux test
make install
cd -
##Install flex
wget ftp://ftp.pbone.net/mirror/apt.sw.be/redhat/el5/en/x86_64/buildtools/RPMS/flex-2.5.35-0.8.el5.rfb.x86_64.rpm
rpm -ivh flex-2.5.35-0.8.el5.rfb.x86_64.rpm
##Install bison
wget ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/6.4/x86_64/os/Packages/byacc-1.9.20070509-7.el6.x86_64.rpm
rpm -ivh byacc-1.9.20070509-7.el6.x86_64.rpm
##Install libedit
wget http://www.thrysoee.dk/editline/libedit-20150325-3.1.tar.gz
tar -xvzf libedit-20150325-3.1.tar.gz
cd libedit-20150325-3.1
sed "/LIBS/s/ncurses/ncursesw/" -i configure && CPPFLAGS=-I/include/ncursesw
./configure
make install
##Install pcap
wget http://www.tcpdump.org/release/libpcap-1.7.4.tar.gz
tar -xf libpcap-1.7.4.tar.gz
cd libpcap-1.7.4
./configure
make all; make install
#============================================================
cd /root
rm -rf master* PROX* DATS* 91897c6b10ec15a0b4901f5ed764f3239696a18c*
git clone https://github.com/nvf-crucio/PROX.git
cd PROX/ 
make
cd /root
rm -rf DATS
wget https://github.com/nvf-crucio/DATS/archive/91897c6b10ec15a0b4901f5ed764f3239696a18c.zip
unzip 91897c6b10ec15a0b4901f5ed764f3239696a18c.zip
mv DATS-91897c6b10ec15a0b4901f5ed764f3239696a18c DATS
cd DATS/
mv tests/prox-configs/ tests/prox-configs.old/
rm -rf dats-patchs/
git clone https://github.com/toandd-viosoft/dats-patchs.git
cp -r dats-patchs/openstack-patchs/prox-configs/ tests/
chmod +x dats.py

sudo sed -i -e 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' /etc/ssh/sshd_config
sudo sed -i -e 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config

sudo sed -i '/GSSAPIAuthentication\ yes/a \\tStrictHostKeyChecking\ no' /etc/ssh/ssh_config
sudo sed -i -e 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' /etc/ssh/ssh_config

sudo service sshd restart

rm -rf /root/.ssh/id*
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
./genkey.sh

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
./copy_keygen.sh 10.64.0.105 root validium2016
sleep 2
./copy_keygen.sh 10.64.0.106 root validium2016
sleep 2
 
