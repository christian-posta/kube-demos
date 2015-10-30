#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Create a pod"
run "cat $(relative pod.yaml)"
run "kubectl --namespace=demos create -f $(relative pod.yaml)"

desc "Hey look, a pod!"
run "kubectl --namespace=demos get pods"

desc "Get the pod's logs"
run "kubectl --namespace=demos logs graceful-demo-pod --follow"

desc "Delete the pod"
run "kubectl --namespace=demos delete pod graceful-demo-pod"
run "kubectl --namespace=demos get pods graceful-demo-pod"

desc "Get the pod's logs"
run "kubectl --namespace=demos logs graceful-demo-pod --follow"
