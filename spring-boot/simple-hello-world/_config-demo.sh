#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


cd $(relative project/simple-hello-world)


desc "Let's create a ConfigMap"
run "cat helloserviceConfigMap.yml"
run "kubectl create -f helloserviceConfigMap.yml"
run "kubectl get configMap"
run "kubectl get configMap helloservice -o yaml"

desc "Update your code to use some application properties"
read -s

desc "Run our app outside kubernetes, but connected to it"
run "mvn spring-boot:run"

desc "Run our app INSIDE kubernetes"
run "mvn fabric8:run"
