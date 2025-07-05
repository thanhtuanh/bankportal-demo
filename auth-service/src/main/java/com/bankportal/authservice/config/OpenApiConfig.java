package com.bankportal.authservice.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.Components;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI authServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Bank Portal - Authentication Service API")
                        .description("RESTful API für Benutzer-Authentifizierung und JWT-Token Management")
                        .version("v1.0.0")
                        .contact(new Contact()
                                .name("Bank Portal Development Team")
                                .email("dev@bankportal.com")))
                .servers(Arrays.asList(
                        new Server()
                                .url("http://localhost:8081")
                                .description("Development Server")))
                .components(new Components()
                        .addSecuritySchemes("bearerAuth", new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("JWT Token für API-Authentifizierung")))
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"));
    }
}
