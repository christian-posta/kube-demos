#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

for NODE in $(kubectl get nodes -o name | cut -f2 -d/); do
    kubectl label node $NODE color- --overwrite >/dev/null 2>&1
done

desc "No labels on nodes"
run "kubectl get nodes \\
    -o go-template='{{range .items}}{{.metadata.name}}{{\"\t\"}}{{.metadata.labels}}{{\"\n\"}}{{end}}'"

desc "Run a service to front our daemon"
run "cat $(relative svc.yaml)"
run "kubectl --namespace=demos create -f $(relative svc.yaml)"

desc "Run our daemon"
run "cat $(relative daemon.yaml)"
run "kubectl --namespace=demos create -f $(relative daemon.yaml)"
run "kubectl --namespace=demos describe ds daemons-demo-daemon"

tmux new -d -s my-session \
    "$(dirname ${BASH_SOURCE})/_daemon_1.sh" \; \
    split-window -h -d "sleep 15; $(dirname $BASH_SOURCE)/_daemon_2.sh" \; \
    attach \;
