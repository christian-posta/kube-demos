#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/ticket-monster-orders.git $(relative project/ticket-monster-orders)"

SOURCE_DIR=$PWD

desc "We now have a project!"
run "cd $(relative project/ticket-monster-orders) && ls -l"

desc "Let's build the project and run locally!"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_orders_1.sh' Enter

run "mvn wildfly-swarm:run"
tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter


desc "let's use mysql instead of hsqldb"
read -s


TEMPLATE_EXISTS=$(oc get template | grep ticket-monster-mysql)
if [[ ! $TEMPLATE_EXISTS ]]; then

    if [ ! -d $SOURCE_DIR/../infra/project/ticket-monster-infra ]; then
        git clone https://github.com/christian-posta/ticket-monster-infra ../../../infra/project/ticket-monster-infra
    fi
    desc "Deploy mysqlorders"
    run "oc create -f ../../../infra/project/ticket-monster-infra/mysql-openshift-template.yml"
fi

tmux split-window -v -d
tmux send-keys -t bottom C-z 'oc get pod --watch' Enter

run "oc process ticket-monster-mysql -v DATABASE_SERVICE_NAME=mysqlorders | oc create -f -"
run "oc deploy mysqlorders --latest"
run "oc logs dc/mysqlorders"


desc "Now let's use mysql and deploy to kubernetes"
run "mvn clean -Pf8,mysql fabric8:deploy"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter

desc "show tables"
run "$SOURCE_DIR/mysql -e 'show tables;'"

read -s

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_port-forward-mysql.sh' Enter

desc "Let's add tables, data to the database using liquibase"
read -s


run "mvn -Pdb-migration-mysql liquibase:status"
run "mvn -Pdb-migration-mysql liquibase:update"
run "mvn -Pdb-migration-mysql liquibase:tag -Dliquibase.tag=v2.0"

# we need to port forward the mysqlorders mysql
# then we need run import.sql
# CONNECT_POD_NAME=$(kubectl get pod | grep -i running | grep ^mysqlorders| awk '{ print $1 }')
# kubectl port-forward $CONNECT_POD_NAME 3306:3306
# mysql ticketmonster -h127.0.0.1 -uticket -pmonster < src/main/resources/import.sql

tmux send-keys -t bottom C-c
sleep 1
tmux send-keys -t bottom C-z 'exit' Enter


## slight of hand.. bounce the UI pod because we've prob changed the tm-search service IP
## be deleting and restarting it. Typically the UI service would deploy its own tm-search with
## appropriate selectors, etc. but we'll hide it by bouncing it here:
oc delete pod $(oc get pod | grep ticket-monster-ui | awk '{print $1}') > /dev/null 2>&1

desc "Go make sure UI works"
read -s
