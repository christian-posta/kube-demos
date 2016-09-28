#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Delete this project"
run "rm -fr $(relative project/simple-hello-world)"