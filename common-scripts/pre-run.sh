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
rm -rf master* PROX* DATS*
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

echo -e "\n\n\n" | ssh-keygen

cat - >copy_keygen.sh <<'EOF'
#!/usr/bin/expect
set host [lrange $argv 0 0]

set username [lrange $argv 1 1]
set password [lrange $argv 2 2]

set timeout 10
spawn /usr/bin/ssh-copy-id -i ~/.ssh/id_rsa.pub $username@$host
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
