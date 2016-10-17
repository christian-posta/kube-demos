#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

MYSQL_POD=$(oc get pod | grep -i running | grep mysqlorders | awk '{print $1}')

desc "Port forward the mysql pod locally"
run "oc port-forward $MYSQL_POD 3306:3306"

