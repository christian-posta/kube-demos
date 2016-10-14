#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Create the blue/v1 service"
run "cat $(relative app-blue-v1.yaml)"
run "kubectl --namespace=demos create -f $(relative app-blue-v1.yaml)"
run "kubectl --namespace=demos get pod"
run "kubectl --namespace=demos get svc"

desc "expose our service to the outside world"
run "oc expose svc/app-blue-v1 --name bluegreen"
run "oc get route"


desc "Start load in tmux, another window"
read -s

desc "Run green/v2 of our app"
run "cat $(relative app-green-v2.yaml)"
run "kubectl --namespace=demos create -f $(relative app-green-v2.yaml)"
run "kubectl --namespace=demos get pod"
run "kubectl --namespace=demos get svc"

desc "Smoke test v2 in another window"
read -s

desc "Everything looks good! Let's upgrade!"
read -s

desc "Patch the route to switch from blue to green"
run "oc patch route/bluegreen -p '{\"spec\": {\"to\": {\"name\": \"app-green-v2\" }}}'"

desc "Does everything look okay? Oh, no? fail back!"
read -s
run "oc patch route/bluegreen -p '{\"spec\": {\"to\": {\"name\": \"app-blue-v1\" }}}'"

desc "BONUS!!!!!! what about A/B weighted routing!?"
read -s

desc "Maybe we just want to treat this as A/B test?"
desc "Note... Blue/Green is NOT the same as A/B, but we'll illustrated weighted routing here:"
read -s

run "oc patch route/bluegreen -p '{\"spec\": { \"alternateBackends\" : [{ \"kind\": \"Service\", \"name\": \"app-green-v2\", \"weight\": 25}], \"to\": {\"weight\": 75}}}'"




