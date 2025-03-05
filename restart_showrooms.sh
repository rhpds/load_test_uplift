#!/bin/bash

# list of openshift clusters and credentials
#

oc get pods -A -l app.kubernetes.io/name=showroom | awk '{print "oc delete pod -n " $1 " " $2 " --wait=false"}'
