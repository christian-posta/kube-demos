#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

IP=$(kubectl --namespace=demos get svc deployment-demo \
        -o go-template='{{.spec.clusterIP}}')

run "minishift ssh -- '\\
    while true; do \\
        curl --connect-timeout 1 -s $IP; \\
        sleep 0.5; \\
    done \\
    '"
