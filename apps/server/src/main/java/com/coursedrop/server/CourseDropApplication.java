package com.coursedrop.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.scheduling.annotation.EnableScheduling;

import org.mybatis.spring.annotation.MapperScan;

import com.coursedrop.server.config.AdminProperties;
import com.coursedrop.server.config.ServerProperties;
import com.coursedrop.server.config.StorageProperties;

@EnableScheduling
@MapperScan("com.coursedrop.server.mapper")
@EnableConfigurationProperties({ StorageProperties.class, ServerProperties.class, AdminProperties.class })
@SpringBootApplication
public class CourseDropApplication {
    public static void main(String[] args) {
        SpringApplication.run(CourseDropApplication.class, args);
    }
}
