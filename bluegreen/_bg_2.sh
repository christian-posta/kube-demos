#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

IP=$(kubectl --namespace=demos get svc app-green-v2 \
        -o go-template='{{.spec.clusterIP}}')

desc "Smoke test our green/v2 app by pointing directly at svc"
run "minishift ssh -- '\\
    while true; do \\
        curl --connect-timeout 1 -s $IP; \\
        sleep 0.5; \\
    done \\
    '"
