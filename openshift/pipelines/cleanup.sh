#!/bin/bash


oc delete dc jenkins nodejs-mongodb-example mongodb --namespace=demos
oc delete svc jenkins jenkins-jnlp mongodb nodejs-mongodb-example --namespace=demos
oc delete route jenkins nodejs-mongodb-example --namespace=demos
oc delete bc nodejs-mongodb-example sample-pipeline --namespace=demos
oc delete is/nodejs-mongodb-example --namespace=demos
oc delete pod $(oc get pod | grep nodejs | awk '{print $1}')


echo "removing docker images that have 'example' in their name"
docker rmi -f $(docker images | grep nodejs-mongodb-example | awk '{print $3}')
docker rmi -f $(docker images | grep nodejs-mongodb-example | awk '{print $3}')