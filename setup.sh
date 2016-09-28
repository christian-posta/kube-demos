#!/bin/bash

. $(dirname ${BASH_SOURCE})/util.sh

desc "The demo namespace does not exist"
run "kubectl get namespaces"

desc "Create a namespace for these demos"
run "cat $(relative demo-namespace.yaml)"
run "kubectl create -f $(relative demo-namespace.yaml)"

desc "For openshift, we need to enable deployer rights"
run "oc policy add-role-to-user edit system:serviceaccount:demos:deployer"

desc "Also enable default service account to talk to Kube API"
run "oc policy add-role-to-user edit system:serviceaccount:demos:default"

desc "Hey look, a namespace!"
run "kubectl get namespaces"

desc "Creating a demo folder for demos"
run "mkdir -p demos"
