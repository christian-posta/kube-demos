#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


rm -fr $(relative project/ticket-monster-orders)

oc delete dc ticket-monster-orders --namespace=demos
oc delete dc  mysqlorders --namespace=demos
oc delete svc tm-orders --namespace=demos
oc delete svc mysqlorders --namespace=demos
#oc delete rc $(oc get rc --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
#oc delete configmap $(oc get configmap --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
oc delete pod $(oc get pod --namespace=demos | grep ticket-monster-orders |awk '{print $1}')
oc delete is ticket-monster-orders --namespace=demos
oc delete bc ticket-monster-orders-s2i --namespace=demos
oc delete build $(oc get builds | grep -i complete | grep ticket-monster-orders | awk '{print $1}')
oc delete pod $(oc get pod | grep Completed | awk '{print $1}')

oc delete template ticket-monster-mysql  --namespace=demos

echo "removing docker images that have 'example' in their name"
docker rmi -f $(docker images | grep ticket-monster-orders | awk '{print $3}')