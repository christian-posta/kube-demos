#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


#desc "Let's build the project and run locally!"
#
#tmux split-window -v -d -c $PWD
#tmux send-keys -t bottom C-z 'while true; do echo foo; sleep 5; done' Enter
#
#run "for i in 'seq 1 3'; do echo bar; done"
#tmux send-keys -t bottom C-c
#tmux send-keys -t bottom C-z 'exit' Enter
#
#
#desc " continue ... "
#read -s


#####################
#SOURCE_DIR=$PWD
#echo "$SOURCE_DIR/../infra/project/ticket-monster-infra"
#
#TEMPLATE_EXISTS=$(oc get template | grep ticket-monster-mysql)
#if [[ ! $TEMPLATE_EXISTS ]]; then
#
#    if [ ! -d $SOURCE_DIR/../infra/project/ticket-monster-infra ]; then
#        git clone https://github.com/christian-posta/ticket-monster-infra ../../../infra/project/ticket-monster-infra
#    fi
#    desc "Deploy mysqlorders"
#    run "oc create -f ../../../infra/project/ticket-monster-infra/mysql-openshift-template.yml"
#fi
######################


desc "show tables"
run "$(relative mysql) -e 'show tables;'"

######################

