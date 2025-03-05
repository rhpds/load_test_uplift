#!/bin/bash

# for each windowsmesh namespace

namespaces=""
namespaces=$(oc get ns | awk '/windowsmesh/ { print $1 }')
echo $namespaces

n=""


for n in $namespaces
do
	virtctl restart winweb01 -n $n
	virtctl restart winweb02 -n $n
	virtctl restart database -n $n
done

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
        oc get vms -A | grep -v Running"

#watch -n10 "echo 'Created winweb03:'; oc get vms -A -l app=winweb03; echo 'Metal Node Capacity:';oc adm top nodes -l node.kubernetes.io/instance-type=$machine_type"

# delete all the VMs
