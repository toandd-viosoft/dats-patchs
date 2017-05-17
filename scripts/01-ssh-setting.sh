#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: 
#    Allow ssh as root (default by Redhat)
#    Allow ssh using password and don't ask (yes/no) at the first time
#    Create and run a script to automatically generate ssh key
#    Create and run a script to automatically copy public ssh key to other servers
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

#Parameters for sshing operation
path="$(pwd)"
#source $path/env.sh

# Allow ssh using password and don't ask (yes/no) at the first time connect to
sudo sed -i -e 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' /etc/ssh/sshd_config
sudo sed -i -e 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config
sudo sed -i '/GSSAPIAuthentication\ yes/a \\tStrictHostKeyChecking\ no' /etc/ssh/ssh_config
sudo sed -i -e 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' /etc/ssh/ssh_config

# Allow sudo from ssh
echo 'Defaults !requiretty' >/etc/sudoers.d/ssh-sudo-without-tty

# Restart ssh service
sudo service sshd restart

# Remove the old ssh key if it exists to avoid failure when running genkey script
#rm -rf /root/.ssh/id*

# Automatically generate ssh key (3 times Enter)
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

# The scripts with 3 parameters, use to copy ssh public key to other servers
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

# Copy ssh key to all hosts in pool
./copy_keygen.sh $TG_IP $USERNAME $PASSWD
sleep 2
./copy_keygen.sh $SUT_IP $USERNAME $PASSWD
sleep 2
./copy_keygen.sh $MANAGER_IP $USERNAME $PASSWD
sleep 2
