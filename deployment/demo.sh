#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

SOURCE_DIR=$PWD


desc "Create a service that fronts any version of this demo"
run "cat $(relative svc.yaml)"
run "kubectl --namespace=demos apply -f $(relative svc.yaml)"

desc "Deploy v1 of our app"
run "cat $(relative deployment.yaml)"
run "kubectl --namespace=demos apply -f $(relative deployment.yaml)"

desc "Check out our deployment"
run "kubectl get deployment"
run "kubectl get pods"
run "kubectl get svc"


tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_deploy_1.sh' Enter

desc "Ready to do a deployment?"
read -s

desc "Update the deployment"
run "cat $(relative deployment.yaml) | sed 's/ v1/ v2/g' | kubectl --namespace=demos apply -f-"

desc "Deployment history"
run "kubectl --namespace=demos rollout history deployment deployment-demo" 

desc "Rollback the deployment"
run "kubectl --namespace=demos rollout undo deployment deployment-demo"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter

desc "clean up"
run "kubectl delete deployment/deployment-demo"
run "kubectl delete svc/deployment-demo"