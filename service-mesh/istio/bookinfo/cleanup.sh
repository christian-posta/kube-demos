#!/bin/bash

VERSION="0.1.6"
. $(dirname ${BASH_SOURCE})/../../../util.sh

istioctl delete route-rule productpage-default
istioctl delete route-rule reviews-default
istioctl delete route-rule ratings-default
istioctl delete route-rule details-default
istioctl delete route-rule reviews-test-v2
istioctl delete route-rule ratings-test-delay
#istioctl delete mixer-rule ratings-ratelimit

kubectl delete -f $(relative ../setup/binaries/istio-$VERSION/samples/apps/bookinfo/bookinfo.yaml)