#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Create the blue/v1 service"
run "cat $(relative app-blue-v1.yaml)"
run "kubectl --namespace=demos create -f $(relative app-blue-v1.yaml)"
run "oc expose svc/app-blue-v1 --name bluegreen"
run "oc get route"


desc "Start load in tmux, another window"
read -s

desc "Run green/v2 of our app"
run "cat $(relative app-green-v2.yaml)"
run "kubectl --namespace=demos create -f $(relative app-green-v2.yaml)"
run "kubectl --namespace=demos get svc"
run "kubectl --namespace=demos get pod"

desc "Smoke test v2 in another window"
read -s

desc "Patch the route to switch from blue to green"
run "oc patch route/bluegreen -p '{\"spec\": {\"to\": {\"name\": \"app-green-v2\" }}}'"

desc "Does everything look okay? Oh, no? fail back!"
run "oc patch route/bluegreen -p '{\"spec\": {\"to\": {\"name\": \"app-blue-v1\" }}}'"
