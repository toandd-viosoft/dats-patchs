#! /bin/bash

sudo yum -y -x 'kernel*' update

sudo sed -i -e 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' /etc/ssh/sshd_config
sudo sed -i -e 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config

sudo sed -i '/GSSAPIAuthentication\ yes/a \\tStrictHostKeyChecking\ no' /etc/ssh/ssh_config
sudo sed -i -e 's/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g' /etc/ssh/ssh_config

sudo service sshd restart

[ -d /opt/nfv-mano ] || mkdir -p /opt/nfv-mano
cd /opt/nfv-mano
# Removing the old source
rm -rf validium.io
# Creating file which contains users's information
cat - >users_information.sh <<'EOF'
export GIT_USERNAME=
export GIT_PASSWD=
EOF

source /opt/nfv-mano/users_information.sh

cat - >get_source.sh <<'EOF'
#!/usr/bin/expect
# Users's information
set username [lrange $argv 0 0]
set password [lrange $argv 1 1]
# Get source code
spawn git clone https://github.com/viosoft-corp/validium.io.git
expect "Username for 'https://github.com': "
send -- "$username\r"
expect "*?github.com': "
send -- "$password\r"
sleep 5
EOF
chmod +x get_source.sh
./get_source.sh $GIT_USERNAME $GIT_PASSWD
