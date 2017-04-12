#!/bin/bash

# we should already have this
#oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:demos:exposecontroller
#oc apply -f http://central.maven.org/maven2/io/fabric8/devops/apps/exposecontroller/2.2.327/exposecontroller-2.2.327-openshift.yml
#oc get cm/exposecontroller -o yaml | sed s/Route/NodePort/g | oc apply -f -

# Turbine
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:demos:turbine
oc apply -f http://central.maven.org/maven2/io/fabric8/kubeflix/turbine-server/1.0.28/turbine-server-1.0.28-openshift.yml

# Hystrix
oc apply -f http://central.maven.org/maven2/io/fabric8/kubeflix/hystrix-dashboard/1.0.28/hystrix-dashboard-1.0.28-openshift.yml

# sleep for a sec to let the exposecontroller do it's thing
sleep 15

TURBINE_URL=$(oc get svc turbine-server -o yaml | grep exposeUrl | tr -s ' ' | cut -d ' ' -f3)
HYSTRIX_DASHBOARD_URL=$(oc get svc hystrix-dashboard -o yaml | grep exposeUrl | tr -s ' ' | cut -d ' ' -f3)

echo "turbine url: $TURBINE_URL"
echo "hystrix-dashboard url: $HYSTRIX_DASHBOARD_URL"