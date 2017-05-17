#!/bin/sh

#Author: ToanDD
#Date created: 20/01/2017
#Description: TBD
#Bash Version: 4.2.46(1)-release
#Copyright (c) 2017, Viosoft Corporation. 
#All rights reserved.

path="$(pwd)"
source $path/env.sh
#Getting machine's IP address
NET=$(route | grep '^default' | grep -o '[^ ]*$')
ipaddr=$(ifconfig $NET  | grep -ie "inet" | grep -ioEe "([0-9]+\.){3}[0-9]+")
ipaddr=($ipaddr)
IP=${ipaddr[0]}
# Checking if this machine is SUT, install OvS dpdk on it
if [ $IP = $SUT_IP ]
then
echo "Preparing some helper scripts for OvS on SUT machine"
echo "..."
cd /root/crucio/ovs-dpdk
# 1. Creating a script to start OvS server
cat - >13-start-ovsdb-server.sh <<'EOF'
#!/bin/sh
rm -f /usr/local/etc/openvswitch/conf.db
ovsdb-tool create
cmd="ovsdb-server"
cmd="$cmd --remote=punix:$OVS_DBSOCK"
cmd="$cmd --remote=db:Open_vSwitch,Open_vSwitch,manager_options"
cmd="$cmd --private-key=db:Open_vSwitch,SSL,private_key"
cmd="$cmd --certificate=db:Open_vSwitch,SSL,certificate"
cmd="$cmd --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert"
cmd="$cmd --pidfile --detach"
$cmd
ovs-vsctl --no-wait init
ovs-vsctl show
EOF
chmod +x 13-start-ovsdb-server.sh

cd /root/crucio/ovs-dpdk
# 2. Creating a script to stop OvS server
cat > 14-stop-ovsdb-server.sh << EOL
#!/bin/sh
ovs-appctl -t ovsdb-server exit
EOL
chmod +x 14-stop-ovsdb-server.sh

# 3. Creating a script to start OvS daemon
cd /root/crucio/ovs-dpdk
cat > 15-start-ovs-vswitchd.sh  << EOF
#!/bin/sh
source ./ovs-dpdk-args.sh
cmd="ovs-vswitchd"
cmd="$cmd --dpdk -vhost_sock_dir $OVS_SOCKDIR $OVS_DPDK_ARGS --"
cmd="$cmd unix:$OVS_DBSOCK"
cmd="$cmd --pidfile --detach"
cmd="$cmd --log-file=$OVS_LOG_FILE"
$cmd
ovs-vsctl set Open_vSwitch . other_config:pmd-cpu-mask=$OVS_PMD_CPU_MASK
ovs-vsctl set Open_vSwitch . other_config:max-idle=$OVS_MAX_IDLE
EOF
chmod +x 15-start-ovs-vswitchd.sh

# 4. Creating a script to stop OvS daemon
cd /root/crucio/ovs-dpdk
cat > 16-stop-ovs-vswitchd.sh << EOL
#!/bin/sh
ovs-appctl -t ovs-vswitchd exit
EOL
chmod +x 16-stop-ovs-vswitchd.sh
else
echo "This isn't SUT, don't need to setup helper scripts for OvS on this machine"
fi
