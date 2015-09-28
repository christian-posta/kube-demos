#!/bin/bash

kubectl --namespace=demos run hostnames --image=kubernetes/serve_hostname --replicas=5

kubectl --namespace=demos describe rc hostnames

kubectl --namespace=demos get pods -l run=hostnames

IPS=($(kubectl --namespace=demos get pods -o yaml -l run=hostnames \
          | grep podIP \
          | cut -f2 -d:))
NODE=$(kubectl get nodes \
            | tail -1 \
            | cut -f1 -d' ')
gcloud compute ssh --zone=us-central1-b $NODE \
    --command "for IP in $IPS; do curl -s \$IP:9376; done"

# Kill a pod.
VICTIM=$(kubectl --namespace=demos get pods -o name -l run=hostnames | tail -1)
kubectl --namespace=demos delete $VICTIM
kubectl --namespace=demos describe rc hostnames

# Kill a node.
NODE=$(kubectl --namespace=demos get pods -l run=hostnames -o wide \
           | tail -1 \
           | awk '{print $NF}')
gcloud compute ssh --zone=us-central1-b $NODE \
    --command "sudo shutdown -r now"
kubectl get nodes
kubectl --namespace=demos get pods -l run=hostnames -o wide
kubectl --namespace=demos describe rc hostnames
