#!/bin/bash

watch "echo 'VMs per Metal Node:'; oc get vmi -A -o jsonpath='{.items[*].metadata.labels.kubevirt\.io/nodeName}' \
        | tr ' ' '\n'   \
        | sort  \
        | uniq -c; \
        echo 'VMs not yet Running:'; \
        oc get vms -A | grep -v Running"
