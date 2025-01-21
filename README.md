# load_test_uplift
A simple shell script to run on the basiton of UpLife and Shift workshop/demo

## To begin the test, just run `./test_create_vm.sh`

## After the test is complete, delete all the appropriate VMs:

 oc delete vms -l app=winweb03 -A
