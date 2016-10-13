# Hystrix, Service Discovery, Spring Boot demo

This demo builds on the previous one. We build a service which calls our hello-world service and we add hystrix and service discovery features.

## What this demos:

* Creating and running a spring boot application on Kubernetes
* Illustrate service chaining and service discvoery
* Illustrate hystrix circuit breaker
 
### Creating and running Spring Boot microservice in Kubernetes

```
$ ./demo.sh
```

This will do the following:

* create a new spring-boot application using start.spring.io/spring initializr
* create a hello-world HTTP/JSON service at http://localhost:8080/api/ip/{name}
* build/run inside spring-boot; you can switch to a new window (tmux!) and run 

```
$ curl http://localhost:8080/api/ip/ceposta
```
 
This *should* blow up in one of two ways:

* Either it will not start because we already have another local spring-boot app using port `8080`
* Service comes up properly, but when we call it, it should blow up because it cannot reach our hello-world service

We blow it up at this point for illustration purposes. We're going to illustrate these things:

* When we debug/run locally, we need to be mindful of what apps are listening on what ports, etc. In kubernetes, *everything* can listen on port `8080`. Yay!
* Should we really be hardcoding URLs and ports in our service? Should we use k8s service discovery for this?

Let's run the simple-hello-world and update the `server.port` property to use `8081` and continue on with the demo:
```
diff --git a/src/main/resources/application.properties b/src/main/resources/application.properties
index 297dee6..da861de 100644
--- a/src/main/resources/application.properties
+++ b/src/main/resources/application.properties
@@ -1,2 +1,2 @@
 spring.application.name=hystrix-hello-world
-#server.port=8081
+server.port=8081
```

Now when we curl, we should see a good response:

```
$ curl http://localhost:8081/api/ip/ceposta
{"ip":"192.168.99.1","hello":{"response":"hello","count":0,"your-name":"ceposta"}}
```

What if we take down the simple-hello-world service? We'll get bad responses again. Let's add hystrix and a fallback:

```
--- a/src/main/java/com/example/HystrixHelloWorldApplication.java
+++ b/src/main/java/com/example/HystrixHelloWorldApplication.java
@@ -1,7 +1,9 @@
 package com.example;
 
+import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
 import org.springframework.boot.SpringApplication;
 import org.springframework.boot.autoconfigure.SpringBootApplication;
+import org.springframework.cloud.client.circuitbreaker.EnableCircuitBreaker;
 import org.springframework.web.bind.annotation.PathVariable;
 import org.springframework.web.bind.annotation.RequestMapping;
 import org.springframework.web.bind.annotation.RequestMethod;
@@ -9,10 +11,12 @@ import org.springframework.web.bind.annotation.RestController;
 import org.springframework.web.client.RestTemplate;
 
 import java.net.InetAddress;
+import java.net.UnknownHostException;
 import java.util.HashMap;
 import java.util.Map;
 
 @SpringBootApplication
+@EnableCircuitBreaker
 public class HystrixHelloWorldApplication {
 
        public static void main(String[] args) {
@@ -26,6 +30,7 @@ public class HystrixHelloWorldApplication {
 class HelloController {
 
 
+    @HystrixCommand(fallbackMethod = "generatedResponse")
     @RequestMapping(value = "/ip/{name}", method = RequestMethod.GET)
     public Map<String, Object> hello(@PathVariable String name) throws Exception {
         RestTemplate template = new RestTemplate();
@@ -39,6 +44,17 @@ class HelloController {
 
         return response;
     }
+
+    public Map<String, Object> generatedResponse(@PathVariable String name) throws UnknownHostException {
+        HashMap<String, Object> response = new HashMap<>();
+        response.put("hello", "This is a generated response!");
+        response.put("ip", InetAddress.getLocalHost().getHostAddress());
+
+        return response;
+    }
 }
``` 


Now let's take down the simple-hello-world service, and we can run it again and curl to get the generated response:

```
$ curl http://localhost:8081/api/ip/ceposta
{"ip":"10.1.2.1","hello":"This is a generated response!"}
```

Lastly, we'll add the service discovery k8s service:

```
--- a/src/main/java/com/example/HystrixHelloWorldApplication.java
+++ b/src/main/java/com/example/HystrixHelloWorldApplication.java
@@ -36,7 +36,7 @@ class HelloController {
         RestTemplate template = new RestTemplate();
         HashMap<String, Object> response = new HashMap<>();
 
-        String url = "http://localhost:8080/api/hello/" + name;
+        String url = "http://simple-hello-world/api/hello/" + name;
         HashMap<String, Object> hello = template.getForEntity(url, HashMap.class).getBody();
 
         response.put("hello", hello);
```
         
Now let the demo continue, but make sure the simple-hello-world service is running inside Kubernetes before you continue. 
Then call the ip service once it's running in k8s!         