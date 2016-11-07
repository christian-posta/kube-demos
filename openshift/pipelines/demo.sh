#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

SOURCE_DIR=$PWD

# Make sure jenkins gets auto-created when deploying a jenkisn pipeline
# check the master-config.yaml file

desc "Create our first pipeline"

TEMPLATE_EXISTS=$(oc get template | grep ticket-monster-mysql)
if [[ ! $TEMPLATE_EXISTS ]]; then

    desc "Let's make sure the jenkins template is there'"
    run "oc create -f https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/v1.4/quickstart-templates/jenkins-ephemeral-template.json"
fi

desc "Create a sample pipeline"
run "oc new-app -f https://raw.githubusercontent.com/openshift/origin/master/examples/jenkins/pipeline/samplepipeline.json"

desc "Go to web console, or continue to kick off the build here"
read -s 

run "oc start-build sample-pipeline"
