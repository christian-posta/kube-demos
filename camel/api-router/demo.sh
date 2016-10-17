#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/api-router.git $(relative project/api-router)"

SOURCE_DIR=$PWD

desc "We now have a project!"
run "cd $(relative project/api-router) && ls -l"

desc "Let's build the project and run locally!"



run "mvn clean install"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_catalog_1.sh' Enter

desc "Start the service"
read -s
run "mvn exec:java"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter


# install FIS image streams
curl -s -L https://raw.githubusercontent.com/jboss-fuse/application-templates/master/fis-image-streams.json | oc create -f - > /dev/null 2>&1

desc "Create a quickstart template"
run "oc create -f quickstart-template.json"

desc "Create our app"
run "oc process api-router-app -v GIT_REPO=https://github.com/christian-posta/api-router,IMAGE_STREAM_NAMESPACE=demos  | oc create -f -"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z "oc logs -f build/$(oc get build | grep -i running | grep api-router | awk '{print $1}')" Enter

desc "See what we've created"
run "oc get pod"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter

run "oc get svc"
run "oc expose svc api-router"