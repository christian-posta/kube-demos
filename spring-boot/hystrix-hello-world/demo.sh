#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh


# we want to be able to interact with the services 
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:demos:exposecontroller > /dev/null 2>&1
oc apply -f http://central.maven.org/maven2/io/fabric8/devops/apps/exposecontroller/2.2.327/exposecontroller-2.2.327-openshift.yml > /dev/null 2>&1
oc get cm/exposecontroller -o yaml | sed s/Route/NodePort/g | oc apply -f - > /dev/null 2>&1

desc "Getting a project from start.spring.io"
desc "spring init --name hystrix-hello-world --boot-version 1.3.7.RELEASE --groupId=com.example --artifactId=hystrix-hello-world --dependencies=web,actuator,cloud-hystrix --build=maven "
read -s
run "spring init --name hystrix-hello-world --boot-version 1.3.7.RELEASE --groupId=com.example --artifactId=hystrix-hello-world --dependencies=web,actuator,cloud-hystrix --build=maven --extract $(relative project/hystrix-hello-world)"

pushd $(relative project/hystrix-hello-world)
desc "We now have a project!"
run "ls -l "


desc "Let's add some functionality"
run "../../_impl-svc.sh"

desc "Open the project in your IDE if you'd like"
read -s

desc "Build and run the project; query the endpoint in a different screen: curl http://localhost:8080/api/hello/ceposta"

tmux split-window -v
tmux select-layout even-vertical
tmux select-pane -t 0
tmux send-keys -t 1 "clear" C-m
tmux send-keys -t 1 "curl -s http://localhost:8080/api/ip/ceposta"

run "mvn spring-boot:run"
backtotop
desc "I'll wait for you to add the circuit breaker"
read -s

desc "Try running again.."
tmux send-keys -t 1 "clear" C-m
tmux send-keys -t 1 "curl -s http://localhost:8080/api/ip/ceposta"

run "mvn spring-boot:run"


desc "Let's add the fabric8 magic!"
desc "mvn io.fabric8:fabric8-maven-plugin:LATEST:setup"
read -s
run "mvn io.fabric8:fabric8-maven-plugin:3.2.28:setup"
run "tail -n 30 pom.xml"

desc "Go update the service to use k8s service discovery"
run "oc get svc"
read -s


desc "Let's deploy our app!"
run "mvn clean install fabric8:deploy"

# let's enable the hystrix stream now
oc label svc/hystrix-hello-world hystrix.enabled=true > /dev/null 2>&1

SERVICE_URL=$(oc get svc hystrix-hello-world -o yaml | grep exposeUrl | awk '{print $2}')

tmux send-keys -t 1 "clear" C-m
tmux send-keys -t 1 "while true; do sleep 1s; curl $SERVICE_URL/api/ip/ceposta; echo; done"

desc "scale down the simple-hello-world service and watch it hit the fallback"
read -s
run "oc scale dc/simple-hello-world --replicas=0"

desc "scale it back up"
run "oc scale dc/simple-hello-world --replicas=1"

tmux send-keys -t 1 C-c

desc "let's install kubeflix"
popd
run "./setup-kubeflix.sh"

tmux send-keys -t 1 "clear" C-m
tmux send-keys -t 1 "while true; do sleep 1s; curl $SERVICE_URL/api/ip/ceposta; echo; done"

desc "scale down the simple-hello-world service and watch it hit the fallback"
read -s
run "oc scale dc/simple-hello-world --replicas=0"

desc "scale it back up"
read -s
run "oc scale dc/simple-hello-world --replicas=1"