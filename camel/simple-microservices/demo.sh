#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/fabric8-hello.git $(relative project/simple-microservices)"

SOURCE_DIR=$PWD

desc "We now have a project with two microservices"
run "cd $(relative project/simple-microservices) && ls -l"

desc "Let's build and deploy the helloswarm service"
run "cd helloswarm"
run "mvn clean install"
run "mvn fabric8:deploy"

desc "see what's been deployed"
run "oc get pod"
run "oc get service"

desc "now let's deploy the client with a circuit breaker"
run "cd ../client-hystrix"
run "mvn clean install"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z 'oc scale dc helloswarm --replicas=0'

run "mvn fabric8:run"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter