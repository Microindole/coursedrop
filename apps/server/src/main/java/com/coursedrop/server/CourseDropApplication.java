package com.coursedrop.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class CourseDropApplication {
  public static void main(String[] args) {
    SpringApplication.run(CourseDropApplication.class, args);
  }
}

