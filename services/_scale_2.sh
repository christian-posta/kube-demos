#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Resize the RC and watch the service backends change"
run "kubectl --namespace=demos scale deploy deployment-demo --replicas=1"
run "kubectl --namespace=demos scale rc deployment-demo --replicas=2"
run "kubectl --namespace=demos scale rc deployment-demo --replicas=5"
