#!/bin/bash
../setup/cli/istioctl delete route-rule $(../setup/cli/istioctl get route-rule)
../setup/cli/istioctl create -f ../setup/project/istio/samples/apps/bookinfo/route-rule-all-v1.yaml 
