#!/bin/bash
. $(dirname ${BASH_SOURCE})/../util.sh

echo "delete mysql"
oc process mysql-persistent -n openshift MYSQL_DATABASE=ticketmonster MYSQL_USER=ticket MYSQL_PASSWORD=monster MYSQL_ROOT_PASSWORD=admin | oc delete -f -

echo "delete ticketmonster"
oc delete dc/ticketmonster
oc delete svc/ticketmonster
oc delete bc/ticketmonster-monolith
oc delete is/ticketmonster-monolith
