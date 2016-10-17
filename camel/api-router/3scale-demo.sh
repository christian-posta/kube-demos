#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Install the 3Scale Gateway template"
run "oc create -f https://raw.githubusercontent.com/3scale/docker-gateway/master/3scale-gateway-openshift-template.yml"

desc "Now run this with the Provider Key:"
desc "oc process 3scale-gateway -v THREESCALE_ADMIN_URL=https://ceposta-admin.3scale.net,THREESCALE_PROVIDER_KEY=  | oc create -f -"