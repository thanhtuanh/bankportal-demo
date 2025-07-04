package com.example.accountservice.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.Components;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI accountServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Bank Portal - Account Service API")
                        .description("RESTful API für Kontenverwaltung, Transaktionen und Geldtransfers")
                        .version("v1.0.0")
                        .contact(new Contact()
                                .name("Bank Portal Development Team")
                                .email("dev@bankportal.com")
                                .url("https://github.com/bankportal/account-service"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8082")
                                .description("Development Server"),
                        new Server()
                                .url("https://api.bankportal.com")
                                .description("Production Server")))
                .components(new Components()
                        .addSecuritySchemes("bearerAuth", new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("JWT Token für API-Authentifizierung")))
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"));
    }
}
