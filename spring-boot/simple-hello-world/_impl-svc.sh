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


echo 'spring.application.name=helloservice' > src/main/resources/application.properties

rm -fr src/test/

mkdir -p src/main/fabric8


awk '/<properties>/{x++} x==1{sub(/<properties>/,"&\n    <spring-cloud.version>Brixton.SR4</spring-cloud.version> \
<spring-cloud-kubernetes.version>0.0.15</spring-cloud-kubernetes.version>")}1' pom.xml > tmp && mv tmp pom.xml


awk '/<\/dependencies>/{x++} x==1{sub(/<\/dependencies>/,"&\n <dependencyManagement> \
<dependencies> \
<dependency> \
    <groupId>org.springframework.cloud</groupId> \
    <artifactId>spring-cloud-dependencies</artifactId> \
    <version>\${spring-cloud.version}</version> \
    <type>pom</type> \
    <scope>import</scope> \
  </dependency> \
  </dependencies>\
</dependencyManagement>")}1' pom.xml > tmp && mv tmp pom.xml

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


cat <<EOF >> src/main/java/com/example/SimpleHelloWorldApplication.java


@RestController()
@RequestMapping("/api")
class HelloController {

    private static int counter = 0;

    @RequestMapping(value = "/hello/{name}", method = RequestMethod.GET)
    public Map<String, Object> hello(@PathVariable String name) throws Exception {
        HashMap<String, Object> response = new HashMap<>();
        response.put("response", "hello");
        response.put("your-name", name);
        response.put("count", counter++);
        return response;
    }
}


EOF

cat <<EOF >> helloserviceConfigMap.yml
kind: ConfigMap
apiVersion: v1
metadata:
  name: helloservice
data:
  application.yaml: |-
    demo:
      message: hello, spring cloud kubernetes from Las Vegas!
EOF
