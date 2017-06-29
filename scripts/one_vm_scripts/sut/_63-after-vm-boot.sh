#!/bin/bash

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

source ./vm-args.sh
cmd='cd /root && ./run-all-after-vm-booting.sh'
first=1
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
# Delete old known VM host
#sed -i.bak "/$VM_IP/d" /root/.ssh/known_hosts
sed -i "/^$VM1_IP.*$/d" /root/.ssh/known_hosts
ssh-keygen -f "/root/.ssh/known_hosts" -R $VM1_IP
# Checking host until it on
echo "=====================VM is booting up=============="
echo " Please wait some minutes (max 10 minutes)"
echo " Pinging until VM up ..."
until ping -c1 $VM_IP &>/dev/null; do :; done
echo "VM is up now, but still need to wait for more than 2 minutes"
# After VM up, it try to connect to default server in 120s (timeout)
# So we wait 150s > 120s
sleep 150
screen -d
# Actually we don't need while loop here, but to make sure in some situations
while true ; do
./copy_keygen.sh $VM_IP $USERNAME $PASSWD
sleep 2
ssh $VM_USER@$VM_IP "$cmd"
ret=$?
[ $ret -eq 0 ] && {
break
}
[ $ret -ne 255 ] && {
echo "Command '$cmd' failed on $VM_IP as $VM_USER"!
exit 1
}
[ $first -ne 0 ] && {
echo "Could not connect to $VM_IP as $VM_USER, retrying..."
first=0
}
sleep 1
done
