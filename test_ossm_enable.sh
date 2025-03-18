#!/bin/bash

# for each windowsmesh namespace
#
# example deployer_domain: apps.rosa-22krx.5ljt.p1.openshiftapps.com

deployer_domain=$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{$.status.domain}')
namespaces=""
namespaces=$(oc get ns | awk '/windowsmesh/ { print $1 }')
echo $namespaces

# does the VM already exist in the namespace?
namespaces_needing_vms=""
n=""

#patch='{ "spec": { "template": { "metadata": { "annotations": { "sidecar.istio.io/inject": "true" } } } } }'

for n in $namespaces
do
	# echo "Creating ServiceMeshMember CRs in namespaces $n..."
	# oc apply -f ./service_mesh_member.yaml -n $n
	#
	# create OSSM object by creating a new file from the template
	user_index=$(echo $n | awk '{gsub(/[^0-9]/, ""); print}')
	sed "s/{{user_index}}/$user_index/g; s/{{deployer_domain}}/$deployer_domain/g" ossm_resources.yaml > ossm_resources_user.yaml
	oc apply -f ./ossm_resources_user.yaml -n $n
	#
	# # echo "oc annotating the winweb01 and winweb02 and database"
	# oc patch vm winweb01 -n $n --type=merge --patch="$(cat ossm_patch.yaml)"
	# oc patch vm winweb02 -n $n --type=merge --patch="$(cat ossm_patch.yaml)"
	# oc patch vm database --type=merge --patch='{"spec":{"template":{"metadata":{"annotations":{ "sidecar.istio.io/inject": "true"}}}}}' -n $n
	#
	# echo "Restarting VMs..."
	# virtctl restart winweb01 -n $n
	# virtctl restart winweb02 -n $n
	# virtctl restart database -n $n
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
