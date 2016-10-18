#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


rm -fr $(relative project/api-router)

oc delete dc api-router-app --namespace=demos
oc delete bc api-router-app --namespace=demos
oc delete svc api-router-app --namespace=demos
oc delete svc api-router --namespace=demos
oc delete is api-router-app --namespace=demos
oc delete template api-router-app --namespace=demos

oc delete build $(oc get builds | grep -i complete | grep api-router-app | awk '{print $1}')
oc delete pod $(oc get pod | grep Completed | awk '{print $1}')

oc delete route api-router

oc delete is fis-java-openshift --namespace=demos
oc delete is fis-karaf-openshift --namespace=demos

docker rmi -f $(docker images | grep api-router-app | awk '{print $3}')

