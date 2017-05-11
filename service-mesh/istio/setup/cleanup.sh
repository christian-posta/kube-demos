#!/bin/bash
. $(dirname ${BASH_SOURCE})/../../../util.sh

rm $(relative cli/istioctl)

# delete addons
kubectl delete deploy/grafana
kubectl delete deploy/prometheus
kubectl delete deploy/servicegraph

kubectl delete svc/grafana
kubectl delete svc/prometheus
kubectl delete svc/servicegraph

kubectl delete cm/prometheus

# delete istio infra
kubectl delete deploy/istio-ingress-controller
kubectl delete deploy/istio-manager
kubectl delete deploy/istio-mixer

kubectl delete svc/istio-ingress-controller
kubectl delete svc/istio-manager
kubectl delete svc/istio-mixer

kubectl delete cm/mixer-config
kubectl delete cm/istio

# some of the new things
kubectl delete cm/prometheus
kubectl delete svc/istio-egress
kubectl delete svc/istio-ingress
kubectl delete svc/zipkin
kubectl delete deploy/istio-egress
kubectl delete deploy/istio-ingress
kubectl delete deploy/zipkin
kubectl delete sa/istio-ingress-service-account 
kubectl delete sa/istio-manager-service-account 
kubectl delete deploy/servicegraph