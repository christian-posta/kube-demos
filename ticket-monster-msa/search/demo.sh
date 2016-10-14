#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/ticket-monster-search.git $(relative project/ticket-monster-search)"


desc "We now have a project!"
run "cd $(relative project/ticket-monster-search) && ls -l"

desc "Let's build the project and run locally!"
run "mvn wildfly-swarm:run"

run "mvn fabric8:deploy"


