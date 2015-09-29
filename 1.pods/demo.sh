#!/bin/bash

kubectl --namespace=demos get pods

kubectl --namespace=demos create -f pod.yaml

kubectl --namespace=demos get pods

kubectl --namespace=demos get pod pods-demo-pod -o yaml | grep podIP

IP=$(kubectl --namespace=demos get pod pods-demo-pod -o yaml \
        | grep podIP \
        | cut -f2 -d:)
NODE=$(kubectl get nodes \
        | tail -1 \
        | cut -f1 -d' ')
gcloud compute ssh --zone=us-central1-b $NODE \
    --command "while true; do curl --connect-timeout 1 -s $IP; sleep 0.5; done"
