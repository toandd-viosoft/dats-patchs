#! /bin/bash

sudo yum -y -x 'kernel*' update

sudo sed -i -e 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' /etc/ssh/sshd_config
sudo sed -i -e 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config

sudo sed -i '/GSSAPIAuthentication\ yes/a \\tStrictHostKeyChecking\ no' /etc/ssh/ssh_config
sudo sed -i -e 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' /etc/ssh/ssh_config

sudo service sshd restart

rm -rf /root/.ssh/id*
rm -rf /root/.ssh/known_hosts
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
./copy_keygen.sh 10.64.0.101 root validium2016
sleep 3
cd /root
scp -r root@10.64.0.101:/root/validium.io .
cd /root/validium.io/crucio-blueprint/crucio-scripts/CRUCIO-SYSTEM-SETUP/host-setup
./crucio_testcase_1_baremetal.sh

