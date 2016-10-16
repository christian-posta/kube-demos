#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/ticket-monster-orders.git $(relative project/ticket-monster-orders)"

SOURCE_DIR=$PWD

desc "We now have a project!"
run "cd $(relative project/ticket-monster-orders) && ls -l"

desc "Let's build the project and run locally!"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_orders_1.sh' Enter

run "mvn wildfly-swarm:run"
tmux send-keys -t bottom C-z 'exit' Enter





#run "mvn fabric8:deploy"