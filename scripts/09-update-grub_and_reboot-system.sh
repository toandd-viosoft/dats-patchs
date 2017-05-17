#!/bin/sh

##############################################################################
#Author: ToanDD
#Date created: 20/01/2017
#Description:
#    This is a important script
#    Getting parameters from  global variables
#    Checking OS's version
#    Updating grub's parameters
#    Creating setup environment script after booting
#    Rebooting system
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.
##############################################################################

path="$(pwd)"
#source $path/env.sh

cores=$(seq -s, $FIRST_ISO_CORE $LAST_ISO_CORE)
echo "====================================================="
echo "The following logical cores are setup for NICs usage:"
echo "====================================================="
echo $cores
echo "====================================================="
# Let's Redhat always boot to default version of kernel, just apply for redhat 7.2
# Firstly checking the version of OS release
os_ver=$(cat /etc/*release* | grep "REDHAT_BUGZILLA_PRODUCT_VERSION" | cut -f2 -d"=")
os_ver=($os_ver)
# echo ${os_ver[1]}
num_ver=${#os_ver[@]}
# echo $num_ver
i=0
while [[ $i < $num_ver ]]
do
    if [ ${os_ver[$i]} = "7.2" ]
    then
        echo "=======Let redhat boot to default kernel========="
        sed -i -e 's/^GRUB_DEFAULT.*/GRUB_DEFAULT=2/g' /etc/default/grub
    fi
    i=`expr $i + 1`
done

sed -i -e "/^GRUB_CMDLINE_LINUX/ s/ quiet.*\"\$/ quiet default_hugepagesz=$DEFAULT_HUGEPAGESZ hugepagesz=$HUGEPAGESZ hugepages=$HUGEPAGES\"/" /etc/default/grub
sed -i -e "/^GRUB_CMDLINE_LINUX/ s/\"\$/ isolcpus=$cores\"/" /etc/default/grub
sed -i -e "/^GRUB_CMDLINE_LINUX/ s/\"\$/ rcu_nocbs=$cores\"/" /etc/default/grub
sed -i -e "/^GRUB_CMDLINE_LINUX/ s/\"\$/ console=ttyS1,115200n8 noirqbalance intel_idle.max_cstate=$IDLE_MAX_CSTATE processor.max_cstate=$P_MAX_CSTATE\"/" /etc/default/grub
cat /etc/default/grub

grub2-mkconfig -o $(readlink -e /etc/grub.conf /etc/grub2.cfg /etc/grub2-efi.cfg)

# Creating a file to store the state before restarting
echo 1 > /opt/flag.txt

# Creating a scripts file to continue running the setup after rebooting
cd $path

cat - >setup_env_after_rebooting.sh <<'EOF'
#!/bin/sh -e
# echo "Running" > /root/test_local.txt
old_state=`cat /opt/flag.txt`
if [ $old_state = 1 ]
then
path=`dirname $0`
source $path/env.sh
echo "============Warning====================="
echo "System is up now"
echo "========================================"
cd $path
./00-after-boot.sh
# Continuing the setup
./10_install_PROX_DATS.sh
./11_install_OvS_on_SUT.sh
elif [ $old_state = 0 ]
then
path=`dirname $0`
source $path/env.sh
echo "============Warning====================="
echo "System is up now"
echo "========================================"
cd $path
./00-after-boot.sh
fi
EOF
chmod +x setup_env_after_rebooting.sh
# Calling to 'setup_env_after_rebooting.sh' script after rebooting
chmod +x /etc/rc.d/rc.local
# echo "echo 1 > /root/test.txt" >> /etc/rc.local
echo "$path/setup_env_after_rebooting.sh" >> /etc/rc.local
# Reboot the system
echo "============Warning====================="
echo "Rebooting the system"
echo "========================================"
reboot
