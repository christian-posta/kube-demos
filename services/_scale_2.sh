#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Resize the RC and watch the service backends change"
run "kubectl --namespace=demos scale rc hostnames --replicas=1"
run "kubectl --namespace=demos scale rc hostnames --replicas=2"
run "kubectl --namespace=demos scale rc hostnames --replicas=5"
