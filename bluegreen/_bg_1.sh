#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

IP=$(oc get route | grep bluegreen | awk '{print $2}')

desc "Run some load at our service through the OpenShift Route"
run "while true; do \\
        curl --connect-timeout 1 -s $IP; \\
        sleep 0.5; \\
    done"
