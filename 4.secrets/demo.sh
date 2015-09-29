#!/bin/bash

kubectl --namespace=demos get pods

kubectl --namespace=demos create -f secret.yaml
kubectl --namespace=demos create -f pod.yaml

kubectl --namespace=demos exec --tty -i secrets-demo-pod sh
