package com.coursedrop.server.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@EnableConfigurationProperties({ StorageProperties.class, ServerProperties.class })
public class AppConfig implements WebMvcConfigurer {
    private final ServerProperties serverProperties;

    public AppConfig(ServerProperties serverProperties) {
        this.serverProperties = serverProperties;
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns(serverProperties.corsAllowedOrigins())
                .allowedMethods("GET", "POST", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}
