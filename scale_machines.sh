#!/bin/bash

# scale machines to $1 on the first cluster found
# Usage: ./scale-machines.sh <number of machines>

c=$(rosa list clusters -o json | jq -r '.[].name')
echo "Would run: rosa edit machinepool --replicas=$1 --cluster=$c metal"

oc get machines -n openshift-machine-api -l machine.openshift.io/cluster-api-machine-role=metal 
echo
oc get machines -n openshift-machine-api -l machine.openshift.io/cluster-api-machine-role=metal -ojsonpath='{range .items[*]}{.status.providerStatus}{"\n"}'



#  phase: Provisioned
#  providerStatus:
#    conditions:
#    - lastTransitionTime: "2025-02-09T20:55:12Z"
#      message: Machine successfully created
#      reason: MachineCreationSucceeded
#      status: "True"
#      type: MachineCreation
#    instanceId: i-05327a379ff1dfc14
#    instanceState: running
