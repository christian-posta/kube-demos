#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../../util.sh

ADDONS=$(relative addons)
INSTALL=$(relative install)

if [ "$1" == "--upstream" ]; then
    echo "installing from upstream..."
    if [ -d "$(relative project/istio)" ]; then
        pushd $(relative project/istio)
        git reset --hard
        git pull
        popd
    else
        git clone https://github.com/istio/istio.git $(relative project/istio)
    fi

    if [ "$2" == "--zipkin" ]; then
        pushd $(relative project/istio)
        curl -s -L https://gist.github.com/christian-posta/d6192ada85ed65a8a99047e38f2779e0/raw | git apply -
        popd
    fi

    ADDONS=$(relative project/istio/install/kubernetes/addons)
    INSTALL=$(relative project/istio/install/kubernetes/istio.yaml)

    #Download upstream client 
    source $(relative project/istio/istio.VERSION)
    curl -s ${ISTIOCTL_URL}/istioctl-osx > $(relative cli/istioctl)
    chmod +x $(relative cli/istioctl)
fi

echo "Using $INSTALL for the installation"
echo "Using $ADDONS for the addons"
if [ "$2" = "--zipkin" ]; then
    echo "Yay! Installing Zipkin too!"
fi
echo "Press <enter> to continue..."
read -s


echo "Let's install the istio addons"
kubectl create -f $ADDONS

if [ "$2" = "--zipkin" ]; then
    curl -s -L https://gist.github.com/christian-posta/c5f61d68913c35cdb3ea005e17a8adbd/raw | kubectl create -f -
fi

echo "Let's install the istio ingress controller, mixer, and manager"
kubectl create -f $INSTALL