# load_test_uplift
A simple shell script to run on the basiton of UpLife and Shift workshop/demo

## Log in to OpenShift

On the ROSA bastion, use `ec2-user` is already logged in to OpenShift.
You can change to that user, or do an `oc login -u cluster-admin ...`

## To begin the test, just run `./test_create_vm.sh`

## After the test is complete, delete all the appropriate VMs:

 oc delete vms -l app=winweb03 -A
