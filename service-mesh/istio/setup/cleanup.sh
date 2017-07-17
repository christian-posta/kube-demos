#!/bin/bash
. $(dirname ${BASH_SOURCE})/../../../util.sh


# delete addons
kubectl delete deploy/grafana
kubectl delete deploy/prometheus
kubectl delete deploy/servicegraph
kubectl delete deploy/zipkin

kubectl delete svc/grafana
kubectl delete svc/prometheus
kubectl delete svc/servicegraph
kubectl delete svc/zipkin

kubectl delete cm/prometheus

# delete istio infra
kubectl delete deploy/istio-egress
kubectl delete deploy/istio-ingress
kubectl delete deploy/istio-pilot
kubectl delete deploy/istio-mixer

kubectl delete svc/istio-ingress
kubectl delete svc/istio-egress
kubectl delete svc/istio-pilot
kubectl delete svc/istio-mixer

kubectl delete cm/istio

kubectl delete sa/istio-ingress-service-account 
kubectl delete sa/istio-pilot-service-account 
