#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../../util.sh

APP_DIR=app

ISTIOCTL="$(which istioctl)"

ISTIO_LIST="$ISTIOCTL list"

if [ "$1" == "--upstream" ]; then
    echo "installing demo from upstream..."
    APP_DIR=$(relative ../setup/project/istio/demos/apps/bookinfo)
    source $(relative ../setup/project/istio/istio.VERSION)
    ISTIOCTL="$(relative ../setup/cli/istioctl)"
    ISTIO_LIST="$ISTIOCTL get"
        
fi

echo "Using APPDIR=$APP_DIR"
echo "Using istioctl from $ISTIOCTL"
echo "Press <enter> to continue..."
read -s 

# Let's find the dashboard URL
GRAFANA_HOST=$(oc get pod $(oc get pod | grep -i running | grep grafana | awk '{print $1 }') -o yaml | grep hostIP | cut -d ':' -f2 | xargs)
GRAFANA_PORT=$(oc get svc/grafana -o yaml | grep nodePort | cut -d ':' -f2 | xargs)
ISTIO_GRAFANA_URL=http://$GRAFANA_HOST\:$GRAFANA_PORT/dashboard/db/istio-dashboard

SERVICE_GRAPH=$(kubectl get po -l app=servicegraph -o jsonpath={.items[0].status.hostIP}):$(kubectl get svc servicegraph -o jsonpath={.spec.ports[0].nodePort})
SERVICE_GRAPH_URL=http://$SERVICE_GRAPH/dotviz




desc "Let's open the grafana and zipkin dashboard"
run "open $ISTIO_GRAFANA_URL; open $SERVICE_GRAPH_URL"

if [ "$2" == "--zipkin" ]; then
    # Let's find the zipkin URL
    ZIPKIN_HOST=$(oc get pod $(oc get pod | grep -i running | grep zipkin | awk '{print $1 }') -o yaml | grep hostIP | cut -d ':' -f2 | xargs)
    ZIPKIN_PORT=$(oc get svc/zipkin -o yaml | grep nodePort | cut -d ':' -f2 | xargs)
    ISTIO_ZIPKIN_URL=http://$ZIPKIN_HOST\:$ZIPKIN_PORT/
    run "open $ISTIO_ZIPKIN_URL"
fi 

desc "let's take a look at the app"
run "cat $(relative $APP_DIR/bookinfo.yaml)"

desc "let's add the istio proxy"
if [ "$2" == "--zipkin" ]; then
    run "$ISTIOCTL kube-inject --hub docker.io/ijsnellf --tag zipkin -f $(relative $APP_DIR/bookinfo.yaml)"
else
    run "$ISTIOCTL kube-inject -f $(relative $APP_DIR/bookinfo.yaml)"    
fi 


desc "deploy the bookinfo app with istio proxy enabled"
if [ "$2" == "--zipkin" ]; then
    run "kubectl apply -f <($ISTIOCTL kube-inject --hub docker.io/ijsnellf --tag zipkin -f $(relative $APP_DIR/bookinfo.yaml))"
else
    run "kubectl apply -f <($ISTIOCTL kube-inject -f $(relative $APP_DIR/bookinfo.yaml))"        
fi 


desc "take a look at the services we now have"
run "kubectl get services"

desc "take a look at the pods we now have"
run "kubectl get pods"

# define the gateway rul
GATEWAY_URL=$(kubectl get po -l istio=ingress -o jsonpath={.items[0].status.hostIP}):$(kubectl get svc istio-ingress -o jsonpath={.spec.ports[0].nodePort})


backtotop
desc "open the bookinfo app in a browser"
read -s 
run "open http://$GATEWAY_URL/productpage"

desc "we should set some routing rules for the istio proxy"
read -s
desc "we currently don't have any rules"
read -s
run "$ISTIO_LIST route-rule"

desc "We need to force all traffic to v1 of the reviews service"
read -s
desc "Let's take a look at the route rules we want to apply"
read -s
run "cat $(relative $APP_DIR/route-rule-all-v1.yaml)"

desc "update the istio routing rules"
run "$ISTIOCTL create -f $(relative $APP_DIR/route-rule-all-v1.yaml)"

backtotop
desc "Now go to the app and make sure all the traffic goes to the v1 reviews"
read -s

desc "now if we list the route rules, we should see our new rules"
run "$ISTIO_LIST route-rule"

desc "we also see that these rules are stored in kubernetes as 'istioconfig'"
desc "we can use vanilla kubernetes TPR to get these configs"
read -s
run "kubectl get istioconfig"
run "kubectl get istioconfig/route-rule-ratings-default  -o yaml"

backtotop

desc "Now.. let's say we want to deploy v2 of the reviews service and route certain customers to it"
read -s
desc "We can implement A/B testing like this"
read -s
desc "Let's take a look at the content based routing rule we will use"
read -s
run "cat $APP_DIR/route-rule-reviews-test-v2.yaml"

desc "Let's make the change"
run "$ISTIOCTL create -f $APP_DIR/route-rule-reviews-test-v2.yaml"

desc "let's look at the route rules"
read -s
run "$ISTIO_LIST route-rule"
run "$ISTIOCTL get route-rule reviews-test-v2"
run "$ISTIOCTL get route-rule reviews-default"

desc "No go to your browser and refresh the app.. should still see v2 of the reviews"
desc "But if you login as jason, you should see the new, v2"

read -s

backtotop

desc "Now we want to test our services."
read -s
desc "We'll want to test just for the 'jason' user and not everyone"
read -s
desc "let's inject some faults between the reviews v2 service and the ratings service"
desc "we'll delay all traffic for 5s. everything should be okay since we have a 10s timeout'"
read -s
desc "see source here: https://github.com/istio/istio/blob/master/demos/apps/bookinfo/src/reviews/reviews-application/src/main/java/application/rest/LibertyRestEndpoint.java#L64"
read -s
run "cat $(relative $APP_DIR/destination-ratings-test-delay.yaml)"
run "$ISTIOCTL create -f $(relative $APP_DIR/destination-ratings-test-delay.yaml)"

backtotop
desc "Now go to the productpage and test the delay"
read -s

desc "We see that the product reviews are not available at all!!"
desc "we've found a bug!"
read -s
desc "Dang! The product page has a timeout of 3s"
desc "https://github.com/istio/istio/blob/master/demos/apps/bookinfo/src/productpage/productpage.py#L140"

read -s
backtotop
desc "We could change the fault injection to a shorter duration"
read -s
desc "cat $APP_DIR/destination-ratings-test-delay.yaml | sed s/5.0/2.5/g | $ISTIOCTL replace"
read -s
desc "Or we should fix the bug in the reviews app (ie, should not be 10s timeout)"
read -s

desc "We already have v3 of our reviews app deployed which contains the fix"
read -s
desc "Let's route some traffic there to see if it's worth upgrading (canary release)"
read -s
desc "We'll direct 50% of the traffic to this new version"
read -s
run "cat $(relative $APP_DIR/route-rule-reviews-50-v3.yaml)"

backtotop
desc "Run some tests to verify the 50/50 split"
read -s

desc "Install our new routing rule"
run "$ISTIOCTL replace -f $(relative $APP_DIR/route-rule-reviews-50-v3.yaml)"

desc "If we're confident now this is a good change, we can route all traffic that way"
run "$ISTIOCTL replace -f $(relative $APP_DIR/route-rule-reviews-v3.yaml)"
