#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

desc "creating obsidian project"
run "oc new-project obsidian"

desc "enter your github access token:"
read TOKEN

curl -s -L -o /tmp/deploy-obsidian.sh https://raw.githubusercontent.com/openshiftio/appdev-documentation/production/scripts/deploy_launchpad_mission.sh
chmod +x /tmp/deploy-obsidian.sh

desc "installing..."
run "/tmp/deploy-obsidian.sh -p obsidian -i admin:admin -g christian-posta:$TOKEN"