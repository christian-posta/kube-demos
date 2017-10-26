
# Note, need minikube to use 3.7 of openshift
# minishift start --memory=4096 --disk-size=30g --openshift-version=v3.7.0-alpha.1
oc new-project istio-system
oc project istio-system
oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account
oc adm policy add-scc-to-user privileged -z istio-ingress-service-account
oc adm policy add-scc-to-user anyuid -z istio-egress-service-account
oc adm policy add-scc-to-user privileged -z istio-egress-service-account
oc adm policy add-scc-to-user anyuid -z istio-pilot-service-account
oc adm policy add-scc-to-user privileged -z istio-pilot-service-account
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user privileged -z default
oc adm policy add-cluster-role-to-user cluster-admin -z default

curl -L https://git.io/getLatestIstio | sh -
ISTIO=`ls | grep istio`
export PATH="$PATH:~/$ISTIO/bin"
cd $ISTIO
oc apply -f install/kubernetes/istio.yaml

oc create -f install/kubernetes/addons/prometheus.yaml
oc create -f install/kubernetes/addons/grafana.yaml
oc create -f install/kubernetes/addons/servicegraph.yaml
oc create -f install/kubernetes/addons/zipkin.yaml
oc expose svc grafana
oc expose svc servicegraph
oc expose svc zipkin