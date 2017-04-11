#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../../util.sh

if [ -d "$(relative project/sb-webmvc-envoy)" ]; then
    pushd $(relative project/sb-webmvc-envoy)
    git pull
    popd
else
    git clone https://github.com/christian-posta/sb-webmvc-envoy.git $(relative project/sb-webmvc-envoy)
fi


desc "Here's our project'"
run "ls -l $(relative project/sb-webmvc-envoy)"

pushd $(relative project/sb-webmvc-envoy/spring-boot-ipaddress-service)

desc "Lets take a look at the ipaddress service"
run "ls -l"

desc "let's build our application"
run "mvn clean install"

desc "let's examine the kubernetes resource files"
run "cat target/classes/META-INF/fabric8/openshift.yml"

desc "let's deploy our service"
run "mvn fabric8:build fabric8:deploy"
run "oc deploy spring-boot-ipaddress-se --latest"
run "oc get pod"



