#!/bin/bash

watch "echo -n 'VMs per Metal Node:'; oc get machines -A | grep metal |wc -l; \
        oc get vmi -A -o jsonpath='{.items[*].metadata.labels.kubevirt\.io/nodeName}' \
        | tr ' ' '\n'   \
        | sort  \
        | uniq -c; \
        echo 'VMs not yet Running:'; \
        oc get vms -A | grep -v Running"
