#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD

desc "Create the blue/v1 service"
run "cat $(relative app-blue-v1.yaml)"
run "kubectl --namespace=demos create -f $(relative app-blue-v1.yaml)"
run "kubectl --namespace=demos get pod"
run "kubectl --namespace=demos get svc"

desc "expose our service to the outside world"
run "oc expose svc/app-blue-v1 --name bluegreen"
run "oc get route"


tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_bg_1.sh' Enter

desc "run some load.."
read -s

desc "Run green/v2 of our app"
run "cat $(relative app-green-v2.yaml)"
run "kubectl --namespace=demos create -f $(relative app-green-v2.yaml)"
run "kubectl --namespace=demos get pod"
run "kubectl --namespace=demos get svc"

tmux split-window -h -d -c $SOURCE_DIR
tmux send-keys -t right C-z './_bg_2.sh' Enter

desc "Everything looks good! Let's upgrade!"
read -s

desc "Patch the route to switch from blue to green"
run "oc patch route/bluegreen -p '{\"spec\": {\"to\": {\"name\": \"app-green-v2\" }}}'"

tmux send-keys -t right C-c
tmux send-keys -t right C-z 'exit' Enter

desc "Does everything look okay? Oh, no? fail back!"
read -s
run "oc patch route/bluegreen -p '{\"spec\": {\"to\": {\"name\": \"app-blue-v1\" }}}'"

desc "BONUS!!!!!! what about A/B weighted routing!?"
read -s

desc "Maybe we just want to treat this as A/B test?"
desc "Note... Blue/Green is NOT the same as A/B, but we'll illustrated weighted routing here:"
read -s

run "oc patch route/bluegreen -p '{\"spec\": { \"alternateBackends\" : [{ \"kind\": \"Service\", \"name\": \"app-green-v2\", \"weight\": 25}], \"to\": {\"weight\": 75}}}'"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter




