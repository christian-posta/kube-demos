# Simple Spring Boot demo

We can demo basic developer experience with the fabric8-maven-plugin developing with Kubernetes. 

## What this demos:

* Creating and running a spring boot application on Kubernetes
* Debguging the application running in Kubernetes
* Config maps + spring-cloud-kubernetes
* Importing to fabric8 CI/CD
 
### Creating and running Spring Boot microservice in Kubernetes

```
$ ./demo.sh
```

This will do the following:

* create a new spring-boot application using start.spring.io/spring initializr
* create a hello-world HTTP/JSON service at http://localhost:8080/api/hello/{name}
* build/run inside spring-boot; you can switch to a new window (tmux!) and run 

```
$ curl http://localhost:8080/api/hello/ceposta
{"response":"hello","count":0,"your-name":"ceposta"}
``` 

* add fabric8-maven-plugin to project
* create openshift/kubernetes yaml & build docker image using openshift s2i (when run against minishift)
** note to point out we didn't touch a Dockerfile or any kubernetes yaml
** also note that things like readinessProbe, service ports, etc are automatically introspected and created
* do a `fabric8:run` to run the application inside kubernetes


### Debugging our app

To debug our newly deployed microservice while it's still running from the previous step, switch to a new window (tmux!), navigate to where you ran the `./demo.sh` script, and run:

```
$ ./_debug.sh
```

This will enable debugging, redploy our app, and port forward to `5005` on the localhost. You can fire up your IDE and connect to port `5005` to debug. 


### Configuration 

To demonstrate using spring-cloud-kubernetes which automatically looks for a config-map with the name of our application (as defined in application.properties) then do the following:

Make sure the fabric8:run/fabric8:debug from the previous steps are *stopped**. Switch to a new window (tmux!), navigate to where you ran the `./demo.sh` script, and run:

```
$ ./_config-demo.sh
```

This will step you through creating a config map, etc. At the appropriate step, when prompted to update the source code, make it look like this:

```
--- src/main/java/com/example/SimpleHelloWorldApplication.java	(revision )
+++ src/main/java/com/example/SimpleHelloWorldApplication.java	(revision )
@@ -1,5 +1,6 @@
 package com.example;
 
+import org.springframework.beans.factory.annotation.Value;
 import org.springframework.boot.SpringApplication;
 import org.springframework.boot.autoconfigure.SpringBootApplication;
 import org.springframework.web.bind.annotation.PathVariable;
@@ -25,12 +26,16 @@
 
     private static int counter = 0;
 
+    @Value("${demo.message}")
+    private String message;
+
     @RequestMapping(value = "/hello/{name}", method = RequestMethod.GET)
     public Map<String, Object> hello(@PathVariable String name) throws Exception {
         HashMap<String, Object> response = new HashMap<>();
         response.put("response", "hello");
         response.put("your-name", name);
         response.put("count", counter++);
+        response.put("message", message);
         return response;
     }
 }

```

Then when we run `mvn spring-boot:run` we should be able to hit the service and see that our changes are pulling properties from the config map:

```
$ curl http://localhost:8080/api/hello/ceposta
{"response":"hello","count":0,"message":"hello, spring cloud kubernetes from Las Vegas!","your-name":"ceposta"}
```

You can also hit the `/health` endpoint and show that we're NOT running inside Kubernetes:

```
$ curl http://localhost:8080/health
{
  "diskSpace": {
    "free": 208848199680,
    "status": "UP",
    "threshold": 10485760,
    "total": 499046809600
  },
  "kubernetes": { "inside": false, "status": "UP" },
  "refreshScope": { "status": "UP" },
  "status": "UP"
}
```

Continue the demo to run inside of kubernetes with `fabric8:run`.
 
To access the service running inside kubernetes, run this:

```
$ SVC_URL=$(minishift service simple-hello-world -n demos --url=true)
$ curl $SVC_URL/api/hello/ceposta 
$ curl $SVC_URL/health 
```

### Importing to fabric8 CI/CD

To import to fabric8 CI/CD, make sure you've got fabric8 CI/CD running in the default namespace and run:

```
$ ./_import.sh
```

### Cleanup

Run the `._cleanup.sh` script to clean up the environment.