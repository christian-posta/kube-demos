#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/ticket-monster-search.git $(relative project/ticket-monster-search)"

SOURCE_DIR=$PWD

desc "We now have a project!"
run "cd $(relative project/ticket-monster-search) && ls -l"

desc "Let's build the project and run locally!"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_search_1.sh' Enter

run "mvn wildfly-swarm:run"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter

run "mvn -Pf8,default fabric8:deploy"

## slight of hand.. bounce the UI pod because we've prob changed the tm-search service IP
## be deleting and restarting it. Typically the UI service would deploy its own tm-search with
## appropriate selectors, etc. but we'll hide it by bouncing it here:
oc delete pod $(oc get pod | grep ticket-monster-ui | awk '{print $1}') > /dev/null 2>&1
