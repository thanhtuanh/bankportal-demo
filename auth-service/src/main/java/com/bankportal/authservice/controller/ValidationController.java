package com.bankportal.authservice.controller;

import com.bankportal.authservice.security.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "JWT Validation", description = "Endpunkte für JWT-Token Validierung (API Gateway)")
public class ValidationController {

    @Autowired
    private JwtUtil jwtUtil;

    @GetMapping("/validate")
    @Operation(
        summary = "JWT Token Validierung",
        description = "Validiert JWT Token für API Gateway. Wird intern vom nginx verwendet."
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Token ist gültig"),
        @ApiResponse(responseCode = "401", description = "Token ist ungültig oder abgelaufen"),
        @ApiResponse(responseCode = "400", description = "Kein Token bereitgestellt")
    })
    public ResponseEntity<Map<String, Object>> validateToken(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestHeader(value = "X-Original-URI", required = false) String originalUri) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Check if Authorization header exists
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                response.put("valid", false);
                response.put("error", "No valid Authorization header");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .header("X-Auth-Status", "missing_token")
                    .body(response);
            }
            
            // Extract token
            String token = authHeader.substring(7);
            
            // Validate token
            if (jwtUtil.isTokenExpired(token)) {
                response.put("valid", false);
                response.put("error", "Token expired");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .header("X-Auth-Status", "expired")
                    .body(response);
            }
            
            // Extract user information
            String username = jwtUtil.extractUsername(token);
            
            if (username == null || username.isEmpty()) {
                response.put("valid", false);
                response.put("error", "Invalid token payload");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .header("X-Auth-Status", "invalid")
                    .body(response);
            }
            
            // Token is valid
            response.put("valid", true);
            response.put("username", username);
            response.put("original_uri", originalUri);
            
            return ResponseEntity.ok()
                .header("X-User", username)
                .header("X-Auth-Status", "valid")
                .body(response);
                
        } catch (Exception e) {
            response.put("valid", false);
            response.put("error", "Token validation failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .header("X-Auth-Status", "error")
                .body(response);
        }
    }

    @PostMapping("/validate")
    @Operation(
        summary = "JWT Token Validierung (POST)",
        description = "Alternative POST-Methode für JWT-Validierung"
    )
    public ResponseEntity<Map<String, Object>> validateTokenPost(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestBody(required = false) Map<String, Object> requestBody) {
        
        // Delegate to GET method
        String originalUri = requestBody != null ? (String) requestBody.get("original_uri") : null;
        return validateToken(authHeader, originalUri);
    }

    @GetMapping("/user-info")
    @Operation(
        summary = "Benutzer-Informationen aus Token",
        description = "Extrahiert Benutzer-Informationen aus gültigem JWT Token"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Benutzer-Informationen erfolgreich extrahiert"),
        @ApiResponse(responseCode = "401", description = "Ungültiger oder fehlender Token")
    })
    public ResponseEntity<Map<String, Object>> getUserInfo(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                response.put("error", "No valid Authorization header");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            String token = authHeader.substring(7);
            
            if (jwtUtil.isTokenExpired(token)) {
                response.put("error", "Token expired");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            String username = jwtUtil.extractUsername(token);
            
            response.put("username", username);
            response.put("token_valid", true);
            response.put("extracted_at", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("error", "Failed to extract user info: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }
    }
}
