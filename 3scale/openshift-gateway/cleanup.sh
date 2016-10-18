#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


oc delete template 3scale-gateway --namespace=demos


oc delete dc threescalegw --namespace=demos
oc delete bc threescalegw --namespace=demos
oc delete svc threescalegw --namespace=demos
oc delete is threescalegw --namespace=demos
oc delete is threescalegw-centos --namespace=demos
oc delete build $(oc get builds | grep -i complete | grep threescalegw | awk '{print $1}')

docker rmi -f $(docker images | grep api-router-app | awk '{print $3}')

