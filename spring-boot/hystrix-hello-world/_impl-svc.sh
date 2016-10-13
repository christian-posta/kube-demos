#!/usr/bin/env bash

if [ ! -d .git ]; then
    git init
    cp ~/dev/.gitignore .
    git add .
    git commit -m 'initial commit'
else
    cp ~/dev/.gitignore .
    git add .
fi


echo 'spring.application.name=hystrix-hello-world' > src/main/resources/application.properties
echo '#server.port=8081' >> src/main/resources/application.properties

rm -fr src/test/

mkdir -p src/main/fabric8


awk '/<properties>/{x++} x==1{sub(/<properties>/,"&\n    <spring-cloud.version>Brixton.SR4</spring-cloud.version> \
<spring-cloud-kubernetes.version>0.0.15</spring-cloud-kubernetes.version>")}1' pom.xml > tmp && mv tmp pom.xml


awk '/<dependencies>/{x++} x==1{sub(/<dependencies>/,"&\n   \
<dependency>\
    <groupId>org.springframework.cloud</groupId>\
    <artifactId>spring-cloud-context</artifactId>\
</dependency>\
<dependency>\
    <groupId>io.fabric8</groupId>\
    <artifactId>spring-cloud-starter-kubernetes</artifactId>\
    <version>\${spring-cloud-kubernetes.version}</version>\
</dependency>\
		")}1' pom.xml > tmp && mv tmp pom.xml


cat <<EOF >> src/main/java/com/example/HystrixHelloWorldApplication.java


@RestController()
@RequestMapping("/api")
class HelloController {


    @RequestMapping(value = "/ip/{name}", method = RequestMethod.GET)
    public Map<String, Object> hello(@PathVariable String name) throws Exception {
        RestTemplate template = new RestTemplate();
        HashMap<String, Object> response = new HashMap<>();

        String url = "http://localhost:8080/api/hello/" + name;
        HashMap<String, Object> hello = template.getForEntity(url, HashMap.class).getBody();

        response.put("hello", hello);
        response.put("ip", InetAddress.getLocalHost().getHostAddress());

        return response;
    }
}


EOF

awk '/org.springframework.boot.autoconfigure.SpringBootApplication;/{x++} x==1{sub(/org.springframework.boot.autoconfigure.SpringBootApplication;/,"&\nimport org.springframework.web.bind.annotation.PathVariable;\
import org.springframework.web.bind.annotation.RequestMapping;\
import org.springframework.web.bind.annotation.RequestMethod;\
import org.springframework.web.bind.annotation.RestController;\
import org.springframework.web.client.RestTemplate;\
\
import java.net.InetAddress;\
import java.util.HashMap;\
import java.util.Map;")}1' src/main/java/com/example/HystrixHelloWorldApplication.java > tmp && mv tmp src/main/java/com/example/HystrixHelloWorldApplication.java


sed -i '' 's/SR6/SR4/g' pom.xml