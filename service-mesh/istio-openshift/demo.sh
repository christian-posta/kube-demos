#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

ISTIOVERSION=istio-0.3.0
APP_NAMESPACE=istio-samples
ISTIOCTL=$ISTIOVERSION/bin/istioctl
APP_DIR=$ISTIOVERSION/samples/bookinfo/kube


desc "we should set some routing rules for the istio proxy"
read -s
desc "we currently don't have any rules"
read -s
run "$ISTIOCTL get routerule"

desc "We need to force all traffic to v1 of the reviews service"
read -s
desc "Let's take a look at the route rules we want to apply"
read -s
run "cat $(relative $APP_DIR/route-rule-all-v1.yaml)"

desc "update the istio routing rules"
run "$ISTIOCTL create -f $(relative $APP_DIR/route-rule-all-v1.yaml) -n $APP_NAMESPACE"

backtotop
desc "Now go to the app and make sure all the traffic goes to the v1 reviews"
read -s

desc "now if we list the route rules, we should see our new rules"
run "$ISTIOCTL get routerule "

desc "we also see that these rules are stored in kubernetes as 'istioconfig'"
desc "we can use vanilla kubernetes CRD to get these configs"
read -s
run "kubectl get routerule "
run "kubectl get routerule/ratings-default  -o yaml"

backtotop

desc "Now.. let's say we want to deploy v2 of the reviews service and route certain customers to it"
read -s
desc "We can implement A/B testing like this"
read -s
desc "Let's take a look at the content based routing rule we will use"
read -s
run "cat $APP_DIR/route-rule-reviews-test-v2.yaml"

desc "Let's make the change"
run "$ISTIOCTL create -f $APP_DIR/route-rule-reviews-test-v2.yaml -n $APP_NAMESPACE"

desc "let's look at the route rules"
read -s
run "$ISTIOCTL get routerule"
run "$ISTIOCTL get routerule reviews-test-v2 -n $APP_NAMESPACE"
run "$ISTIOCTL get routerule reviews-default -n $APP_NAMESPACE"

desc "Now go to your browser and refresh the app.. should still see v1 of the reviews"
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
desc "see source here: https://github.com/istio/istio/blob/master/samples/bookinfo/src/reviews/reviews-application/src/main/java/application/rest/LibertyRestEndpoint.java#L79"
read -s
run "cat $(relative $APP_DIR/route-rule-ratings-test-delay.yaml )"
run "$ISTIOCTL create -f $(relative $APP_DIR/route-rule-ratings-test-delay.yaml ) -n $APP_NAMESPACE"

backtotop
desc "Now go to the productpage and test the delay"
read -s

desc "We see that the product reviews are not available at all!!"
desc "we've found a bug!"
read -s
desc "Dang! The product page has a timeout of 3s"
desc "https://github.com/istio/istio/blob/master/samples/bookinfo/src/productpage/productpage.py#L231"

read -s
backtotop
desc "We could change the fault injection to a shorter duration"
read -s
desc "cat $APP_DIR/route-rule-ratings-test-delay.yaml  | sed s/5.0/2.5/g | $ISTIOCTL replace"
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
run "$ISTIOCTL replace -f $(relative $APP_DIR/route-rule-reviews-50-v3.yaml) -n $APP_NAMESPACE"

desc "If we're confident now this is a good change, we can route all traffic that way"
run "$ISTIOCTL replace -f $(relative $APP_DIR/route-rule-reviews-v3.yaml) -n $APP_NAMESPACE"
