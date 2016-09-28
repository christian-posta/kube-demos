#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Run some pods under a replication controller"
run "cat $(relative rc.yaml)"
run "kubectl --namespace=demos create -f $(relative rc.yaml)"

desc "Look what I made!"
run "kubectl --namespace=demos describe rc hostnames"

desc "These are the pods that were created"
run "kubectl --namespace=demos get pods -l run=hostnames"

trap "" SIGINT
IPS=($(kubectl --namespace=demos get pods -l run=hostnames \
          -o go-template='{{range .items}}{{.status.podIP}}{{"\n"}}{{end}}'))
desc "SSH into my cluster and access the pods"
run "kubectl --namespace=demos get pods -l run=hostnames \\
    -o go-template='{{range .items}}{{.status.podIP}}{{\"\\n\"}}{{end}}'"
run "minishift ssh -- '\\
    for IP in ${IPS[*]}; do \\
        curl --connect-timeout 1 -s \$IP:9376 && echo; \\
    done \\
    '"

desc "Kill a pod"
VICTIM=$(kubectl --namespace=demos get pods -o name -l run=hostnames | tail -1)
run "kubectl --namespace=demos delete $VICTIM"
run "kubectl --namespace=demos get pods -l run=hostnames"

desc "Let's cleanup and delete that deployment"
run "kubectl --namespace=demos delete rc hostnames"

#Leave out kill a node for now as we're doing locally
#desc "Kill a node"
#NODE=$(kubectl --namespace=demos get pods -l run=hostnames -o wide \
#               | tail -1 \
#               | awk '{print $NF}')
#run "kubectl --namespace=demos get pods -l run=hostnames -o wide"
#run "gcloud compute ssh --zone=us-central1-b $NODE --command '\\
#    sudo shutdown -r now; \\
#    '"
#while true; do
#    run "kubectl --namespace=demos get node $NODE"
#    status=$(kubectl --namespace=demos get node $NODE | tail -1 | awk '{print $3}')
#    if [ "$status" == "NotReady" ]; then
#        break
#    fi
#done
#run "kubectl --namespace=demos get pods -l run=hostnames -o wide"
#run "kubectl --namespace=demos describe rc hostnames"
