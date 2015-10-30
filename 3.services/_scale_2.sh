#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Resize the RC and watch the service backends change"
run "kubectl --namespace=demos scale rc hostnames --replicas=1"
run "kubectl --namespace=demos scale rc hostnames --replicas=2"
run "kubectl --namespace=demos scale rc hostnames --replicas=5"

desc "Fire up a cloud load-balancer"
run "kubectl --namespace=demos get svc hostnames -o yaml \\
    | sed 's/ClusterIP/LoadBalancer/' \\
    | kubectl replace -f -"
while true; do
    run "kubectl --namespace=demos get svc hostnames -o yaml | grep loadBalancer -A 4"
    if kubectl --namespace=demos get svc hostnames \
        -o go-template='{{index (index .status.loadBalancer.ingress 0) "ip"}}' \
        >/dev/null 2>&1; then
        break
    fi
done
