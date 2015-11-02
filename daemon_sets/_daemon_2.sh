#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Color each node, slowly"
run "for NODE in \$(kubectl get nodes -o name | grep -i master | cut -f2 -d/); do \\
    kubectl label node \$NODE color=red; \\
    kubectl --namespace=demos describe ds daemons-demo-daemon; \\
    sleep 15; \\
done"
