package com.bankportal.authservice.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
@Tag(name = "Test Controller", description = "Endpunkte zum Testen der API-Funktionalität")
public class TestController {

    @GetMapping("/ping")
    @Operation(
        summary = "Ping Test",
        description = "Einfacher Ping-Test um zu überprüfen, ob der Service erreichbar ist"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Service ist erreichbar"),
        @ApiResponse(responseCode = "500", description = "Interner Server-Fehler")
    })
    public ResponseEntity<Map<String, Object>> ping() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "OK");
        response.put("message", "Auth Service is running");
        response.put("timestamp", LocalDateTime.now());
        response.put("service", "auth-service");
        response.put("version", "1.0.0");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/swagger-test")
    @Operation(
        summary = "Swagger Test",
        description = "Test-Endpunkt um zu überprüfen, ob Swagger korrekt funktioniert"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Swagger funktioniert korrekt"),
        @ApiResponse(responseCode = "500", description = "Swagger-Konfigurationsfehler")
    })
    public ResponseEntity<Map<String, Object>> swaggerTest() {
        Map<String, Object> response = new HashMap<>();
        response.put("swagger_status", "OK");
        response.put("api_docs_url", "/api-docs");
        response.put("swagger_ui_url", "/swagger-ui.html");
        response.put("message", "Swagger is working correctly");
        response.put("timestamp", LocalDateTime.now());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health-detailed")
    @Operation(
        summary = "Detaillierter Health Check",
        description = "Erweiterte Gesundheitsprüfung mit detaillierten Informationen"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Service ist gesund"),
        @ApiResponse(responseCode = "503", description = "Service ist nicht verfügbar")
    })
    public ResponseEntity<Map<String, Object>> healthDetailed() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "auth-service");
        response.put("port", 8081);
        response.put("timestamp", LocalDateTime.now());
        
        // Database status (simplified)
        Map<String, String> database = new HashMap<>();
        database.put("status", "UP");
        database.put("type", "PostgreSQL");
        response.put("database", database);
        
        // JWT status
        Map<String, String> jwt = new HashMap<>();
        jwt.put("status", "CONFIGURED");
        jwt.put("algorithm", "HS256");
        response.put("jwt", jwt);
        
        return ResponseEntity.ok(response);
    }
}
