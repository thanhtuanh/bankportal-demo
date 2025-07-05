package com.bankportal.authservice.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@Tag(name = "Health Check", description = "Service Health and Status Endpoints")
public class HealthController {

    @GetMapping("/health")
    @Operation(
        summary = "Service Health Check",
        description = "Überprüft den Status des Auth Service"
    )
    @ApiResponse(responseCode = "200", description = "Service ist gesund und läuft")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "auth-service");
        response.put("timestamp", LocalDateTime.now());
        response.put("version", "1.0.0");
        response.put("message", "Auth Service is running successfully");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status")
    @Operation(
        summary = "Service Status",
        description = "Detaillierte Statusinformationen des Auth Service"
    )
    @ApiResponse(responseCode = "200", description = "Detaillierte Statusinformationen")
    public ResponseEntity<Map<String, Object>> status() {
        Map<String, Object> response = new HashMap<>();
        response.put("service_name", "Bank Portal Auth Service");
        response.put("status", "RUNNING");
        response.put("uptime", System.currentTimeMillis());
        response.put("timestamp", LocalDateTime.now());
        response.put("java_version", System.getProperty("java.version"));
        response.put("spring_profile", System.getProperty("spring.profiles.active", "default"));
        
        // Memory info
        Runtime runtime = Runtime.getRuntime();
        Map<String, Object> memory = new HashMap<>();
        memory.put("total", runtime.totalMemory());
        memory.put("free", runtime.freeMemory());
        memory.put("used", runtime.totalMemory() - runtime.freeMemory());
        memory.put("max", runtime.maxMemory());
        response.put("memory", memory);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/swagger-test")
    @Operation(
        summary = "Swagger Test Endpoint",
        description = "Test-Endpunkt um zu überprüfen, ob Swagger korrekt funktioniert"
    )
    @ApiResponse(responseCode = "200", description = "Swagger funktioniert korrekt")
    public ResponseEntity<Map<String, Object>> swaggerTest() {
        Map<String, Object> response = new HashMap<>();
        response.put("swagger_status", "OK");
        response.put("api_docs_url", "/api-docs");
        response.put("swagger_ui_url", "/swagger-ui.html");
        response.put("message", "Swagger is working correctly");
        response.put("timestamp", LocalDateTime.now());
        response.put("endpoints", new String[]{
            "/api/health",
            "/api/status", 
            "/api/swagger-test",
            "/api/auth/validate",
            "/api/auth/user-info"
        });
        
        return ResponseEntity.ok(response);
    }
}
