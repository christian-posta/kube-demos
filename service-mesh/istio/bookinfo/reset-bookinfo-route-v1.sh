#!/bin/bash
VERSION="0.1.6"
istioctl delete route-rule $(istioctl get route-rule)
istioctl create -f ../setup/binaries/istio-$VERSION/samples/apps/bookinfo/route-rule-all-v1.yaml 
