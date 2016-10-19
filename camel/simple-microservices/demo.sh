#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/fabric8-hello.git $(relative project/simple-microservices)"

SOURCE_DIR=$PWD

desc "We now have a project with two microservices"
run "cd $(relative project/simple-microservices) && ls -l"
run "git checkout origin/ceposta-fix-swarm-generator"

desc "Let's build and deploy the helloswarm service"
run "cd helloswarm"
run "mvn clean install"
run "mvn fabric8:deploy"

desc "now let's deploy the client"
run "cd ../client"
run "mvn clean install"

run "mvn fabric8:run"

desc "now let's deploy the circtui breaker client"
run "cd ../client-hystrix"
run "mvn clean install"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z 'oc scale dc helloswarm --replicas=0'

run "mvn fabric8:run"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter