# OpenStack-Neutron-Validation-Scripts
This repository contains OpenStack Neutron Validation BASH scripts

# External and Internal API network check 
OpenStack_API_Check.sh

This Script will create a token to get some info from Openstack like tenants details and network details. If we get the result then test is pass otherwise failed

# Tenant to Tenant Networking with Different Subnet
Tenant_Network_Test.sh

For tenant to tenant networking I used following steps.

•	Create first tenant, tenant network, tenant subnet.

•	Create second tenant, tenant network, tenant subnet.

•	Create router in admin tenant and add both tenant interface to it.

•	Create 2 VMs instance into two different tenant network.

•	Add security rule for PING and SSH testing.

•	Ping to each other using network namespace.

To force all VMs should spin into same blade and to test tenant to tenant network into cross blade use –availability_zone=nova:<compute hostname> extra parameter into nova boot command. We are assuming each compute host is running to separate blade. So by using –availability_zone we can achieve our goal to spin the VMs into same blade or different blades. Use same script just add one more parameter in to nova boot command.
  
e.g. nova boot --flavor <falvor name> --image <image name> --nic net-id=<net id> –availability_zone=nova:<compute hostname> --security-group default --key-name <key name> <vm name>

# External/Floating Outgoing/Incoming Network Test
External_Network_Test.sh

I have used following steps to test this.

•	Create tenant network, tenant subnet.

•	Create shared router

•	For external network I have created external network ext-net outside of script because we have to do some manual stuff here. For external networking make sure physical Ethernet port is added into external bridge br-ex and network configuration file ifcfg-br-ex and ifcfg-ethX is created with relevant info.

•	Add tenant network interface to router and set gateway of router to external network.

•	Create VM instance into tenant network.

•	Create and assign floating IP to VM.

•	Add security rule for PING and SSH testing.

•	For external/outgoing access ping to 8.8.8.8 (google DNS) from VM and for floating incoming access ssh to VM using floating IP from outside
