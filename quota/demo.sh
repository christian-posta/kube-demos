#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "There is no quota"
run "kubectl --namespace=demos get quota"

desc "Install quota"
run "cat $(relative quota.yaml)"
run "kubectl --namespace=demos create -f $(relative quota.yaml)"
run "kubectl --namespace=demos describe quota demo-quota"

desc "Create a large pod - should fail"
run "cat $(relative pod1.yaml)"
run "kubectl --namespace=demos create -f $(relative pod1.yaml)"
run "kubectl --namespace=demos describe quota demo-quota"

desc "Create a pod with no limits - should fail"
run "cat $(relative pod2.yaml)"
run "kubectl --namespace=demos create -f $(relative pod2.yaml)"
run "kubectl --namespace=demos describe quota demo-quota"

desc "There are no default limits"
run "kubectl --namespace=demos get limits"

desc "Set default limits"
run "cat $(relative limits.yaml)"
run "kubectl --namespace=demos create -f $(relative limits.yaml)"
run "kubectl --namespace=demos describe limits demo-limits"

desc "Create a pod with no limits - should succeed now"
run "cat $(relative pod2.yaml)"
run "kubectl --namespace=demos create -f $(relative pod2.yaml)"
run "kubectl --namespace=demos describe quota demo-quota"
