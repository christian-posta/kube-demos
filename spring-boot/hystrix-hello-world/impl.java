package com.example;

import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.circuitbreaker.EnableCircuitBreaker;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.net.InetAddress;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
@EnableCircuitBreaker
public class HystrixHelloWorldApplication {

	public static void main(String[] args) {
		SpringApplication.run(HystrixHelloWorldApplication.class, args);
	}
}


@RestController()
@RequestMapping("/api")
class HelloController {


    @HystrixCommand(fallbackMethod = "fallback")
    @RequestMapping(value = "/ip/{name}", method = RequestMethod.GET)
    public Map<String, Object> hello(@PathVariable String name) throws Exception {
        RestTemplate template = new RestTemplate();
        HashMap<String, Object> response = new HashMap<>();

        String url = "http://simple-hello-world/api/hello/" + name;
        HashMap<String, Object> hello = template.getForEntity(url, HashMap.class).getBody();

        response.put("hello", hello);
        response.put("ip", InetAddress.getLocalHost().getHostAddress());

        return response;
    }

    public Map<String, Object> fallback(@PathVariable String name) throws Exception {
        HashMap<String, Object> response = new HashMap<>();
        response.put("fallback", "could not reach service");
        response.put("name", name);
        return response;

    }
}
