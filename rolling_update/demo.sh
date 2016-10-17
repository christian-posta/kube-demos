#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


desc "Create a service that fronts any version of this demo"
run "cat $(relative svc.yaml)"
run "kubectl --namespace=demos create -f $(relative svc.yaml)"

desc "Run v1 of our app"
run "cat $(relative rc-v1.yaml)"
run "kubectl --namespace=demos create -f $(relative rc-v1.yaml)"
run "kubectl --namespace=demos get pods -l demo=update"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_rolling_1.sh' Enter

desc "Prep the load"
read -s

desc "Do a rolling update to v2"
run "cat $(relative rc-v2.yaml)"
run "kubectl --namespace=demos rolling-update \\
    update-demo-rc-v1 -f $(relative rc-v2.yaml) --update-period=5s"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter

