#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


cd $(relative project/simple-hello-world)

desc "Make sure fabric8:run is already running!"
read -s

tmux split-screen -v
tmux select-layout even-vertical
SERVICE_IP=$(oc get svc | grep simple-hello-world | awk '{print $2}')
tmux send-keys -t 2 "clear" C-m
tmux send-keys -t 2 "minishift ssh -- curl -s http://$SERVICE_IP/api/hello/ceposta"

desc "Let's debug and port forward"
run "mvn fabric8:debug"
