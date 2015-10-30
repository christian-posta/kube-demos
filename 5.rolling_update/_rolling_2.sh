#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "Do a rolling update to v2"
run "cat $(relative rc-v2.yaml)"
run "kubectl --namespace=demos rolling-update \\
    update-demo-rc-v1 -f $(relative rc-v2.yaml) --update-period=5s"
