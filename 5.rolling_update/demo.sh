#!/bin/bash

kubectl --namespace=demos create -f svc.yaml

kubectl --namespace=demos create -f rc-v1.yaml

IP=$(kubectl --namespace=demos get svc update-demo-svc -o yaml \
          | grep clusterIP \
          | cut -f2 -d:)
NODE=$(kubectl get nodes \
            | tail -1 \
            | cut -f1 -d' ')
gcloud compute ssh --zone=us-central1-b $NODE \
    --command "while true; do curl --connect-timeout 1 -s $IP; sleep 0.2; done"

kubectl --namespace=demos rolling-update update-demo-rc-v1 -f rc-v2.yaml --update-period=10s
