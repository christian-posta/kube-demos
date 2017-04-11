#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../../util.sh

desc "Let's install the istio addons"
run "kubectl create -f $(relative addons)"

desc "Let's install the istio ingress controller, mixer, and manager"
run "kubectl create -f $(relative install)"