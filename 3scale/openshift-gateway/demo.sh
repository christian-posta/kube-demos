#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Install the 3Scale Gateway template"
run "oc create -f https://raw.githubusercontent.com/3scale/docker-gateway/master/3scale-gateway-openshift-template.yml"

desc "enter your provider key"
read PROVIDER_KEY

desc "Creating gateway"
run "oc process 3scale-gateway -v THREESCALE_ADMIN_URL=https://ceposta-admin.3scale.net,THREESCALE_PROVIDER_KEY=$PROVIDER_KEY  | oc create -f -"