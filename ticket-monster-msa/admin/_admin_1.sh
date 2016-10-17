#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

until $(curl --output /dev/null --silent --head --fail http://localhost:8080/health); do
    sleep 5
done


desc "Find all events via admin"
run "curl -s http://localhost:8080/admin/forge/events | pretty-json"

