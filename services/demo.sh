#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

if kubectl --namespace=demos get rc hostnames >/dev/null 2>&1; then
    desc "Revisit our replication controller"
    run "kubectl --namespace=demos get rc hostnames"
else
    desc "Let's return to hostnames, run some pods under a replication controller"
    run "kubectl --namespace=demos create -f $(relative ../replication_controllers/rc.yaml)"
    run "kubectl --namespace=demos get pods -l run=hostnames"

fi

run "kubectl --namespace=demos get pods -l run=hostnames \\
    -o go-template='{{range .items}}{{.status.podIP}}{{\"\\n\"}}{{end}}'"

desc "Expose the RC as a service"
run "kubectl --namespace=demos expose rc hostnames \\
    --port=80 --target-port=9376"

desc "Have a look at the service"
run "kubectl --namespace=demos describe svc hostnames"

IP=$(kubectl --namespace=demos get svc hostnames \
    -o go-template='{{.spec.clusterIP}}')
desc "See what happens when you access the service's IP"
run "minishift ssh -- '\\
    for i in \$(seq 1 10); do \\
        curl --connect-timeout 1 -s $IP && echo; \\
    done \\
    '"
run "minishift ssh -- '\\
    for i in \$(seq 1 500); do \\
        curl --connect-timeout 1 -s $IP && echo; \\
    done | sort | uniq -c; \\
    '"

desc "Let's cleanup and delete that deployment"
run "kubectl --namespace=demos delete rc hostnames"
run "kubectl --namespace=demos delete svc hostnames"

echo "Manually show the scaling part by using tmux"
#tmux new -d -s my-session \
#    "$(dirname ${BASH_SOURCE})/_scale_1.sh" \; \
#    split-window -h -d "sleep 15; $(dirname $BASH_SOURCE)/_scale_2.sh" \; \
#    attach \;
