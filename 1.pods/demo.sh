#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "There are no running pods"
run "kubectl --namespace=demos get pods"

desc "Create a pod"
run "cat $(relative pod.yaml)"
run "kubectl --namespace=demos create -f $(relative pod.yaml)"

desc "Hey look, a pod!"
run "kubectl --namespace=demos get pods"

desc "Get the pod's IP"
run "kubectl --namespace=demos get pod pods-demo-pod -o yaml | grep podIP"

trap "" SIGINT
IP=$(kubectl --namespace=demos get pod pods-demo-pod -o yaml \
        | grep podIP \
        | cut -f2 -d:)
desc "SSH into my cluster and access the pod"
run "gcloud compute ssh --zone=us-central1-b $SSH_NODE --command '\\
    for i in \$(seq 1 10); do \\
        curl --connect-timeout 1 -s $IP; \\
        sleep 1; \\
    done\\
    '"
