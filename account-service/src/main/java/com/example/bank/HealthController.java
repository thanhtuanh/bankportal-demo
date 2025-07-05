package com.example.bank;

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
        description = "Überprüft den Status des Account Service"
    )
    @ApiResponse(responseCode = "200", description = "Service ist gesund und läuft")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "account-service");
        response.put("timestamp", LocalDateTime.now());
        response.put("version", "1.0.0");
        response.put("description", "Bank Portal Account Management Service");
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/info")
    @Operation(
        summary = "Service Information",
        description = "Detaillierte Informationen über den Account Service"
    )
    @ApiResponse(responseCode = "200", description = "Service-Informationen")
    public ResponseEntity<Map<String, Object>> info() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "account-service");
        response.put("version", "1.0.0");
        response.put("description", "Bank Portal Account Management Service");
        response.put("features", new String[]{
            "Account Management",
            "Money Transfer",
            "Balance Inquiry",
            "Transaction History"
        });
        response.put("timestamp", LocalDateTime.now());
        
        return ResponseEntity.ok(response);
    }
}
