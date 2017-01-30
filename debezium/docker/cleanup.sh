#!/bin/bash

CONTAINERS="zookeeper kafka mysql connect mysqlterm watcher"

kill -14 $(ps aux | grep minishift | grep vnNTL | awk '{print $2}') > /dev/null 2>&1


tmux kill-pane -t 2 
tmux kill-pane -t 1 

docker rm -f $CONTAINERS > /dev/null 2>&1

