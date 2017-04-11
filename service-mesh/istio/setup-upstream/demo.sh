#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../../util.sh

if [ -d "$(relative project/istio)" ]; then
  pushd $(relative project/istio)
  git pull
  popd
else
    git clone https://github.com/istio/istio.git $(relative project/istio)
fi

echo "Let's install the istio addons"
kubectl create -f $(relative project/istio/kubernetes/istio-install)

echo "Let's install the istio ingress controller, mixer, and manager"
kubectl create -f $(relative project/istio/kubernetes/addons)