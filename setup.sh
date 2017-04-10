#!/bin/bash

. $(dirname ${BASH_SOURCE})/util.sh

desc "The demo namespace does not exist"
run "oc new-project demos"

desc "For openshift, we need to enable deployer rights"
run "oc policy add-role-to-user edit system:serviceaccount:demos:deployer"

desc "Also enable default service account to talk to Kube API"
run "oc policy add-role-to-user edit system:serviceaccount:demos:default"
run "oc adm policy add-scc-to-user anyuid system:serviceaccount:demos:default"

# enable this so that apps can see configmaps
run "oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default -n $(oc project -q)"

desc "Hey look, a namespace!"
run "kubectl get namespaces"

