#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../../util.sh

ADDONS=$(relative addons)
INSTALL=$(relative install)

if [ "$1" == "--upstream" ]; then
    echo "installing from upstream..."
    if [ -d "$(relative project/istio)" ]; then
        pushd $(relative project/istio)
        git pull
        popd
    else
        git clone https://github.com/istio/istio.git $(relative project/istio)
    fi
    ADDONS=$(relative project/istio/kubernetes/addons)
    INSTALL=$(relative project/istio/kubernetes/istio-install)
fi

echo "Using $INSTALL for the installation"
echo "Using $ADDONS for the addons"

echo "Let's install the istio addons"
kubectl create -f $ADDONS

echo "Let's install the istio ingress controller, mixer, and manager"
kubectl create -f $INSTALL