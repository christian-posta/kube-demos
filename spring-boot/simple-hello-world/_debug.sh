#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


cd $(relative project/simple-hello-world)

desc "Make sure fabric8:run is already running!"
read -s

desc "Let's debug and port forward"
run "mvn fabric8:debug"
