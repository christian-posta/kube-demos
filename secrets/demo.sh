#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Create a secret"
run "cat $(relative secret.yaml)"
run "kubectl --namespace=demos create -f $(relative secret.yaml)"

desc "Create a pod which uses that secret"
run "cat $(relative pod.yaml)"
run "kubectl --namespace=demos create -f $(relative pod.yaml)"

while true; do
    run "kubectl --namespace=demos get pod secrets-demo-pod"
    status=$(kubectl --namespace=demos get pod secrets-demo-pod | tail -1 | awk '{print $3}')
    if [ "$status" == "Running" ]; then
        break
    fi
done
run "kubectl --namespace=demos exec --tty -i secrets-demo-pod sh"
