#!/bin/bash

# for each *-userN namespace
# * Delete extraneous VMs
# * Set number of cores to 1 for windows
# * Delete the Gateway, DS, VS


namespaces="windowsmesh-user1"
namespaces=$(oc get ns | awk '/windows.*user. / { print $1 }')
echo "################################"
echo "Namespaces to clean up:"
echo "$namespaces"
echo "################################"

# do extraneous VMs already exist in the namespace?
namespaces_needing_vms=""
n=""

for n in $namespaces
do
	# DELETE EXTRANEOUS VMS
	echo
	echo "Checking $n for unknown VMs..."
	bad_vms=$(oc get vms -n $n -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -vE 'winweb01|winweb02')
	echo "Bad VMs: $bad_vms"
	# oc delete vm $bad_vms -n $n &

	# DELETE OSSM OBJECTS
        echo
	echo "Checking namespace $n for OSSM objects..."
	delete_commands=$(oc get virtualservices.networking.istio.io,gateways.networking.istio.io,destinationrules.networking.istio.io -n $n -ojsonpath='{range .items[*]}{"oc delete "}{.kind}{" "}{.metadata.name}{" -n "}{.metadata.namespace}{"\n"}' | grep -v 'delete List')

	IFS=$'\n' read -r -d '' -a delete_commands_list  <<< "$delete_commands"

	for delete_cmd in "${delete_commands_list[@]}"; 
	do 
		echo "Deleting: $delete_cmd"
		eval $delete_cmd
	done
	echo "################################"
		
done
