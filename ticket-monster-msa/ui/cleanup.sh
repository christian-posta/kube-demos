#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


rm -fr $(relative project/ticket-monster-ui)

oc delete dc $(oc get dc --namespace=demos | grep ticket-monster-ui | awk '{print $1}') --namespace=demos
oc delete svc ticket-monster-ui --namespace=demos
#oc delete rc $(oc get rc --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
#oc delete configmap $(oc get configmap --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
oc delete route ticketmonster --namespace=demos
oc delete pod $(oc get pod --namespace=demos | grep ticket-monster-ui |awk '{print $1}')
oc delete is ticket-monster-ui --namespace=demos
oc delete bc ticket-monster-ui --namespace=demos

echo "removing docker images that have 'example' in their name"
docker rmi -f $(docker images | grep ticket-monster-ui | awk '{print $3}')