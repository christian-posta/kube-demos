#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../../util.sh

VERSION="0.1.6"
ADDONS=$(relative binaries/istio-$VERSION/install/kubernetes/addons)
INSTALL=$(relative binaries/istio-$VERSION/install/kubernetes/istio.yaml)

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

    ADDONS=$(relative project/istio/install/kubernetes/addons)
    INSTALL=$(relative project/istio/install/kubernetes/istio.yaml)
    VERSION="master"

    #Download upstream client 
    source $(relative project/istio/istio.VERSION)
    curl -s ${ISTIOCTL_URL}/istioctl-osx > $(relative project/bin/istioctl)
    chmod +x $(relative project/bin/istioctl)
else
    if [ ! -d "$(relative binaries/istio-$VERSION)" ]; then
        rm -fr $(relative binaries/istio-*)
        pushd $(relative binaries)
        curl -L -O "https://github.com/istio/istio/releases/download/$VERSION/istio-$VERSION-osx.tar.gz"
        tar -xzf "istio-$VERSION-osx.tar.gz"
        popd
    fi 
fi

echo "Using version:  $VERSION"
echo "Using $INSTALL for the installation"
echo "Using $ADDONS for the addons"

echo "Press <enter> to continue..."
read -s


echo "Let's install the istio addons"
kubectl create -f $ADDONS

echo "Let's install the istio ingress controller, mixer, and manager"
kubectl create -f $INSTALL


#####
# Install notes
# download 0.1.6
# https://github.com/istio/istio/releases/download/0.1.6/istio-0.1.6-osx.tar.gz
# unpack the tar file
# now the istio-0.1.6 has a folder structure with addons, install, and bin