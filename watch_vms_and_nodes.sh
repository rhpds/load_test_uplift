#!/bin/bash

watch "oc get nodes -l 'beta.kubernetes.io/instance-type=i3.metal'; \
        echo -n 'VMs per Node:';  \
        oc get vmi -A -o jsonpath='{.items[*].metadata.labels.kubevirt\.io/nodeName}' \
        | tr ' ' '\n'   \
        | sort  \
        | uniq -c; \
        echo 'VMs not yet Running:'; \
        oc get vms -A | grep -v Running;"
