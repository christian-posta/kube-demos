#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Run some pods under a replication controller"
run "kubectl --namespace=demos run hostnames \\
    --image=gcr.io/google_containers/serve_hostname:1.1 --replicas=5"

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
run "gcloud compute ssh --zone=us-central1-b $SSH_NODE --command '\\
    for IP in ${IPS[*]}; do \\
        curl --connect-timeout 1 -s \$IP:9376 && echo; \\
    done \\
    '"

desc "Kill a pod"
VICTIM=$(kubectl --namespace=demos get pods -o name -l run=hostnames | tail -1)
run "kubectl --namespace=demos delete $VICTIM"
run "kubectl --namespace=demos get pods -l run=hostnames"
run "kubectl --namespace=demos describe rc hostnames"

desc "Kill a node"
NODE=$(kubectl --namespace=demos get pods -l run=hostnames -o wide \
               | tail -1 \
               | awk '{print $NF}')
run "kubectl --namespace=demos get pods -l run=hostnames -o wide"
run "gcloud compute ssh --zone=us-central1-b $NODE --command '\\
    sudo shutdown -r now; \\
    '"
while true; do
    run "kubectl --namespace=demos get node $NODE"
    status=$(kubectl --namespace=demos get node $NODE | tail -1 | awk '{print $3}')
    if [ "$status" == "NotReady" ]; then
        break
    fi
done
run "kubectl --namespace=demos get pods -l run=hostnames -o wide"
run "kubectl --namespace=demos describe rc hostnames"
