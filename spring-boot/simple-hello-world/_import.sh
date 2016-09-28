#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


cd $(relative project/simple-hello-world)

desc "Let's import our project to an awesome CI/CD system"
read -s
run "mvn fabric8:import -Dfabric8.namespace=default"
