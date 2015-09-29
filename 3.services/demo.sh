#!/bin/bash

kubectl --namespace=demos run hostnames --image=kubernetes/serve_hostname --replicas=5

kubectl --namespace=demos expose rc hostnames --port=80 --target-port=9376

kubectl --namespace=demos describe svc hostnames

IP=$(kubectl --namespace=demos get svc hostnames -o yaml \
          | grep clusterIP \
          | cut -f2 -d:)
NODE=$(kubectl get nodes \
            | tail -1 \
            | cut -f1 -d' ')
gcloud compute ssh --zone=us-central1-b $NODE \
    --command "while true; do curl --connect-timeout 1 -s $IP; sleep 0.5; done"
gcloud compute ssh --zone=us-central1-b $NODE \
    --command "for i in \$(seq 1 500); do curl --connect-timeout 1 -s $IP; done | sort | uniq -c"

gcloud compute ssh --zone=us-central1-b $NODE \
    --command "while true; do curl --connect-timeout 1 -s $IP; sleep 0.5; done"
kubectl --namespace=demos scale rc hostnames --replicas=1
kubectl --namespace=demos scale rc hostnames --replicas=2
kubectl --namespace=demos scale rc hostnames --replicas=10
