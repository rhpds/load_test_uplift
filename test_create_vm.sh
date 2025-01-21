#!/bin/bash

# for each windowsnetworking namespace

namespaces=""
namespaces=$(oc get ns | awk '/windowsnetworking/ { print $1 }')
echo $namespaces

# does the VM already exist in the namespace?
namespaces_needing_vms=""
n=""

for n in $namespaces
do
	echo "checking $n for winweb03"
	echo $n
	if $(oc get vms winweb03 -n $n)
	then
		continue
	else
		echo "adding $n to list of namespaces."
		namespaces_needing_vms+="$n "
	fi
done

echo $namespaces_needing_vms

# in whatever namespace there aren't any, deploy them.
echo "creating VMs"

for n in $namespaces_needing_vms
do
	echo "#### Creating VM winweb03 in namespace $n"
	export n
	oc apply -f - <<EOF
$(cat winweb03.yaml | envsubst)
EOF

done

#
# make the the VM works
#

read "chicken"

# get machine type
machine_type=$(oc get machines -A -l 'machine.openshift.io/cluster-api-machine-type=metal' -o jsonpath='{.items[0].metadata.labels.machine\.openshift\.io/instance-type}')
echo "#### Machine Type: $machine_type"

# watch the VMs and the nodes
watch "echo 'VMs per Metal Node:'; oc get vmi -A -o jsonpath='{.items[*].metadata.labels.kubevirt\.io/nodeName}' \
        | tr ' ' '\n'   \
        | sort  \
        | uniq -c; \
        echo 'VMs not yet Running:'; \
        oc get vms -A -l app=winweb03 | grep -v Running"

#watch -n10 "echo 'Created winweb03:'; oc get vms -A -l app=winweb03; echo 'Metal Node Capacity:';oc adm top nodes -l node.kubernetes.io/instance-type=$machine_type"

# delete all the VMs
