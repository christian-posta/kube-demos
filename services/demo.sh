#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


if kubectl --namespace=demos get deploy deployment-demo >/dev/null 2>&1; then
    desc "Revisit our deployment"
    run "kubectl --namespace=demos get deploy deployment-demo"
else
    desc "Let's return to deployment ..."
    run "kubectl --namespace=demos create -f $(relative ../deployment/deployment.yaml)"
    run "kubectl --namespace=demos get pods -l demo=deployment"

fi

run "kubectl --namespace=demos get pods -l demo=deployment \\
    -o go-template='{{range .items}}{{.status.podIP}}{{\"\\n\"}}{{end}}'"

desc "Expose the deployment as a service"
run "kubectl --namespace=demos expose deploy deployment-demo \\
    --port=80"

desc "Have a look at the service"
run "kubectl --namespace=demos describe svc deployment-demo"

IP=$(kubectl --namespace=demos get svc deployment-demo \
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

desc "Let's do some scaling"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_scale_1.sh' Enter

desc "Resize the RC and watch the service backends change"
run "kubectl --namespace=demos scale deploy deployment-demo --replicas=1"
run "kubectl --namespace=demos scale deploy deployment-demo --replicas=2"
run "kubectl --namespace=demos scale deploy deployment-demo --replicas=5"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter

desc "Let's cleanup and delete that deployment"
run "kubectl --namespace=demos delete deploy deployment-demo"
run "kubectl --namespace=demos delete svc deployment-demo"
