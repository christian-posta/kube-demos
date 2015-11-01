#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "There is no quota"
run "kubectl --namespace=demos get quota"

desc "Install a quota"
run "cat $(relative quota.yaml)"
run "kubectl --namespace=demos create -f $(relative quota.yaml)"

desc "Create a large pod"
run "cat $(relative pod.yaml)"
run "kubectl --namespace=demos create -f $(relative pod.yaml)"
