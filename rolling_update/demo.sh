#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Create a service that fronts any version of this demo"
run "cat $(relative svc.yaml)"
run "kubectl --namespace=demos create -f $(relative svc.yaml)"

desc "Run v1 of our app"
run "cat $(relative rc-v1.yaml)"
run "kubectl --namespace=demos create -f $(relative rc-v1.yaml)"

tmux new -d -s my-session \
    "$(dirname ${BASH_SOURCE})/_rolling_1.sh" \; \
    split-window -h -d "sleep 15; $(dirname $BASH_SOURCE)/_rolling_2.sh" \; \
    attach \;
