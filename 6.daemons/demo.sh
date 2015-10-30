#!/bin/bash

for NODE in $(kubectl get nodes -o name | cut -f2 -d/); do
    kubectl label node $NODE color- --overwrite
done

kubectl --namespace=demos create -f svc.yaml

kubectl --namespace=demos create -f daemon.yaml
kubectl --namespace=demos describe ds daemons-demo-daemon

for NODE in $(kubectl get nodes -o name | cut -f2 -d/); do
    kubectl label node $NODE color- --overwrite
    sleep 30
done &
kubectl --namespace=demos describe ds daemons-demo-daemon


IP=$(kubectl --namespace=demos get svc daemon-demo-svc -o yaml \
          | grep clusterIP \
          | cut -f2 -d:)
NODE=$(kubectl get nodes \
            | tail -1 \
            | cut -f1 -d' ')
gcloud compute ssh --zone=us-central1-b $NODE \
    --command "while true; do curl --connect-timeout 1 -s $IP; sleep 0.2; done"
