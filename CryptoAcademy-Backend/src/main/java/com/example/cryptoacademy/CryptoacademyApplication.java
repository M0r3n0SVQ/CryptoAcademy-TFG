package com.example.cryptoacademy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class CryptoacademyApplication {

	public static void main(String[] args) {
		SpringApplication.run(CryptoacademyApplication.class, args);
	}

}
