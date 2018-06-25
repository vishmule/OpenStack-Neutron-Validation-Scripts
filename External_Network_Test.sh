#!/bin/bash

#Source the admin credentials ###
source ~/keystonerc_admin

#Variables definition. These variables are required for all the neutron operation. #######
network_name=demo-net
subnet_name=demo-subnet
subnet_address=10.0.0.0/24
router_name=demo-router
external_network_name=ext-net
external_subnet_name=ext-subnet
external_subnet_address=192.168.122.0/24
logfile=./`hostname`.neutron_external_nw_validation.log
line1="-----------------------------------------------------------------------------------------------------------------------------"
line2="#############################################################################################################################"

#create internal network with subnet ###
echo $line1|tee -a $logfile;echo -e " Creating internal network $network_name and subnet $subnet_name\n" |tee -a $logfile; echo $line1 2>&1 |tee -a $logfile
neutron net-create $network_name 2>&1 |tee -a $logfile
neutron subnet-create --name $subnet_name $network_name $subnet_address 2>&1 |tee -a $logfile;echo $line2 |tee -a $logfile
 
#create internal network with subnet ###
echo $line1|tee -a $logfile;echo -e " Creating internal network $network_name and subnet $subnet_name\n" |tee -a $logfile; echo $line1 2>&1 |tee -a $logfile
neutron net-create $network_name 2>&1 |tee -a $logfile
neutron subnet-create --name $subnet_name $network_name $subnet_address 2>&1 |tee -a $logfile;echo $line2 |tee -a $logfile

# Create one VM instance into $network_name network. Change the flavor according to your requirement. ##
echo $line1|tee -a $logfile;echo -e " Creating one VM instance in $network_name network..\n" |tee -a $logfile; echo $line1 2>&1 |tee -a $logfile
nova keypair-add --pub-key ~/.ssh/id_rsa.pub tenant-key 2>&1 |tee -a $logfile
network_id=`neutron net-list|awk '/'$network_name'/ {print $2}'`
nova boot --flavor custom.flavor --image cirros --nic net-id=$network_id --security-group default --key-name tenant-key $network_name-vm 2>&1 |tee -a $logfile
echo $line1|tee -a $logfile;echo -e "\n Waiting for 60 seconds to start SSH Daemon after the VM start....." 2>&1 |tee -a $logfile
sleep 60

echo -e "\n To access external network from $network_name-vm we need one router with external network..." 2>&1 |tee -a $logfile;echo $line1|tee -a $logfile
#Create router and add internal network interface and set gateway to external network ### 
echo $line1|tee -a $logfile;echo -e " Creating router $router_name and adding internal interface from $subnet_name and setting $external_network_name network gateway for external access..\n" |tee -a $logfile ;echo $line1 2>&1 |tee -a $logfile
neutron router-create $router_name 2>&1 |tee -a $logfile
neutron router-interface-add $router_name $subnet_name 2>&1 |tee -a $logfile
neutron router-gateway-set $router_name $external_network_name 2>&1 |tee -a $logfile

echo -e "\n Router with added interface details" 2>&1 |tee -a $logfile
neutron router-port-list $router_name 2>&1 |tee -a $logfile;echo $line2 |tee -a $logfile

echo $line1|tee -a $logfile;echo -e "Adding security rule for SSH and PING test..\n" |tee -a $logfile;echo $line1 2>&1 |tee -a $logfile
# Add security group rule for ping and SSH test ### 2>&1 |tee -a $logfile
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0 2>&1 |tee -a $logfile
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0 2>&1 |tee -a $logfile

echo $line1|tee -a $logfile;echo -e "Testing PING from $network_name-vm to external network like 8.8.8.8 (google DNS)..\n"|tee -a $logfile; echo $line1 2>&1 |tee -a $logfile
internal_ip=`nova list|awk '/'$network_name'/ {print $12}'|cut -d= -f2`
echo -e "\n ip netns exec qdhcp-$network_id ssh -n -oStrictHostKeyChecking=no cirros@$internal_ip ping -c3 8.8.8.8 \n" 2>&1 |tee -a $logfile
ip netns exec qdhcp-$network_id ssh -n -oStrictHostKeyChecking=no cirros@$internal_ip ping -c3 8.8.8.8 2>&1 |tee -a $logfile;echo $line2 |tee -a $logfile
