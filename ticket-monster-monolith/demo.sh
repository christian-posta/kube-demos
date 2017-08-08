#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

GITHASH=master

if [ ! -d $(relative project/monolith) ]; then
    echo "clone project..."
    git clone https://github.com/ticket-monster-msa/monolith $(relative project/monolith)
    pushd project/monolith 
    git checkout $GITHASH
    popd
fi



if [[ "$(oc get dc/mysql 2>&1)" == *"not found"* ]]; then 
    echo "installing mysql database"
    oc process mysql-persistent -n openshift MYSQL_DATABASE=ticketmonster MYSQL_USER=ticket MYSQL_PASSWORD=monster MYSQL_ROOT_PASSWORD=admin | oc create -f -
else 
    echo "skipping mysql installation"
fi


if [[ "$(oc get dc/ticketmonster 2>&1)" == *"not found"* ]]; then 
    echo "building ticketmonster for mysql"
    pushd $(relative project/monolith)
    mvn clean install -Pmysql-openshift
    cd target/openshift
    oc new-build --binary=true --strategy=source --image-stream=wildfly:10.0 --name=ticketmonster-monolith --env MYSQL_DATABASE=ticketmonster --env MYSQL_USER=ticket --env MYSQL_PASSWORD=monster
    oc start-build ticketmonster-monolith --from-dir=. --follow=true
    oc new-app --name=ticketmonster --image-stream=ticketmonster-monolith
    popd
else 
    echo "skipping ticketmonster installation"
fi


