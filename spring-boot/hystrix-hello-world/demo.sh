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


desc "We now have a project!"
run "cd $(relative project/hystrix-hello-world)"
run "ls -l "


desc "Let's add some functionality"
run "../../_impl-svc.sh"

desc "Open the project in your IDE if you'd like"
read -s

desc "Build and run the project; query the endpoint in a different screen: curl http://localhost:8080/api/hello/ceposta"
run "mvn spring-boot:run"

desc "I'll wait for you to add the circuit breaker"
read -s

desc "Try running again.."
run "mvn spring-boot:run"

desc "Let's add the fabric8 magic!"
desc "mvn io.fabric8:fabric8-maven-plugin:LATEST:setup"
read -s
run "mvn io.fabric8:fabric8-maven-plugin:3.1.71:setup"
run "tail -n 30 pom.xml"

desc "Go update the service to use k8s service discovery"
read -s


desc "Let's deploy our app!"
run "mvn clean install fabric8:deploy"

# let's enable the hystrix stream now
oc label svc/hystrix-hello-world hystrix.enabled=true > /dev/null 2>&1

