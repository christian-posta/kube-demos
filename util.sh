#!/bin/bash

readonly  reset=$(tput sgr0)
readonly  green=$(tput bold; tput setaf 2)
readonly yellow=$(tput bold; tput setaf 3)
readonly   blue=$(tput bold; tput setaf 6)

function desc() {
    maybe_first_prompt
    echo "$blue# $@$reset"
    prompt
}


function prompt() {
    echo -n "$yellow\$ $reset"
}

started=""
function maybe_first_prompt() {
    if [ -z "$started" ]; then
        prompt
        started=true
    fi
}

function run() {
    maybe_first_prompt
    echo "$green$1$reset" | pv -qL 25
    sleep 0.5
    eval "$1"
    r=$?
    read -d '' -t 0.1 -n 10000 # clear stdin
    prompt
    read -s
    return $r
}

function relative() {
    for arg; do
        echo "$(realpath $(dirname $(which $0)))/$arg" | sed "s|$(realpath $(pwd))|.|"
    done
}

SSH_NODE=$(kubectl get nodes | tail -1 | cut -f1 -d' ')
