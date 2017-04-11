#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../../util.sh

desc "let's take a look at one of the pods"
run "cat $(relative app/echo-app.yaml)"

desc "now let's add the sidecar proxy"
run "istioctl kube-inject -f $(relative app/echo-app.yaml)"

desc "let's add an echo-server with the proxy enabled"
run "kubectl apply -f <(istioctl kube-inject -f $(relative app/echo-app.yaml))"

desc "let's add a client to call the echo server"
run "kubectl apply -f <(istioctl kube-inject -f $(relative app/logic-app.yaml))"

desc "show pods"
run "kubectl get pod"

ECHO_POD=$(kubectl get pod | grep ^echo | awk '{ print $1 }')
desc "send requests from echo pod to logic pod"
run "kubectl exec $ECHO_POD -c app /bin/client -- -url http://logic/demo-text-here --count 10"

LOGIC_POD=$(kubectl get pod | grep ^logic | awk '{ print $1 }')
desc "send requests from logic pod to echo pod"
run "kubectl exec $LOGIC_POD -c app /bin/client -- -url http://echo/demo-text-there --count 10"