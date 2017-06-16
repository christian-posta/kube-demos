#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


desc "enter your access token"
read ACCESS_TOKEN

desc "enter your admin site prefix (ie, prefix-admin.3scale.net)"
read PREFIX

desc "Create Secrets"
run "oc secret new-basicauth apicast-configuration-url-secret --password=\"https://$ACCESS_TOKEN@$PREFIX-admin.3scale.net\""

desc "Creating gateway"
run "curl -s -L https://raw.githubusercontent.com/3scale/3scale-amp-openshift-templates/2.0.0.GA-redhat-2/apicast-gateway/apicast.yml | sed 's/3scale-amp20/registry.access.redhat.com\/3scale-amp20/g' | oc new-app -f -"

desc "Creating route"
run "oc expose svc/apicast"

desc "now create your API on 3scale, promote it to production, and try to curl it!"
read -s