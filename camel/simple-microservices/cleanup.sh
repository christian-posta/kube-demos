#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


rm -fr $(relative project/simple-microservices)

oc delete dc helloswarm --namespace=demos
oc delete dc client --namespace=demos
oc delete svc helloswarm --namespace=demos
oc delete svc svc --namespace=demos
oc delete pod $(oc get pod --namespace=demos | grep helloswarm |awk '{print $1}')
oc delete pod $(oc get pod --namespace=demos | grep client |awk '{print $1}')
oc delete is helloswarm --namespace=demos
oc delete is client --namespace=demos
oc delete bc helloswarm-s2i --namespace=demos
oc delete bc client-s2i --namespace=demos
oc delete bc client-hystrix-s2i --namespace=demos
oc delete rc $(oc get rc | grep -i client-hystrix | awk '{print $1}') --namespace=demos
oc delete build $(oc get builds | grep -i complete | grep helloswarm | awk '{print $1}')
oc delete build $(oc get builds | grep -i complete | grep client | awk '{print $1}')
oc delete pod $(oc get pod | grep Completed | awk '{print $1}')

echo "removing docker images that have 'example' in their name"
docker rmi -f $(docker images | grep helloswarm | awk '{print $3}')
docker rmi -f $(docker images | grep client | awk '{print $3}')