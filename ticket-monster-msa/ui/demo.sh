#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/ticket-monster-ui.git $(relative project/ticket-monster-ui)"


desc "We now have a project!"
run "cd $(relative project/ticket-monster-ui/web) && ls -l"


desc "Let's build the Docker image and deploy to OpenShift"
read -s

desc "Create a new build in OpenShift"
run "oc new-build --binary=true --name ticket-monster-ui"
run "oc start-build ticket-monster-ui  --from-dir=."

BUILD_ID=$(oc get build | grep ticket | grep Running | awk '{print $1}')
run "oc logs -f build/$BUILD_ID"

desc "let's deploy the UI now!"
run "oc new-app ticket-monster-ui"

desc "check status"
run "oc status"
run "oc get pod"

desc "Create an openshift route"
run "oc expose svc ticket-monster-ui --name=ticketmonster"
run "oc get route"

ROUTE_ID=$(oc get route | grep ticketmonster | awk '{print $2}')
run "open http://$ROUTE_ID"