#!/bin/bash


oc delete dc $(oc get dc --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
oc delete deployment $(oc get deployment --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
oc delete svc $(oc get svc --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
oc delete rc $(oc get rc --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
oc delete configmap $(oc get configmap --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
oc delete route $(oc get route --namespace=demos | grep ^[a-z] | awk '{print $1}') --namespace=demos
oc delete pod $(oc get pod --namespace=demos | awk '{print $1}')

