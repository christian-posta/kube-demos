#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

until $(curl --output /dev/null --silent --fail http://localhost:8181/catalog/category); do
    sleep 5
done


desc "Query the category"
run "curl -s http://localhost:8181/catalog/category | pretty-json"

desc "Query the products"
run "curl -s http://localhost:8181/catalog/product | pretty-json"
