// src/main/java/com/bankportal/authservice/controller/AuthController.java
package com.bankportal.authservice.controller;

import java.net.URI;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import com.bankportal.authservice.dto.LoginRequest;
import com.bankportal.authservice.dto.LoginResponse;
import com.bankportal.authservice.dto.RegisterRequest;
import com.bankportal.authservice.model.UserEntity;
import com.bankportal.authservice.service.AuthService;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Benutzer-Authentifizierung und JWT-Token Management")
public class AuthController {

    private final AuthService authService;

    @PostMapping(value = "/register", consumes = "application/json", produces = "text/plain")
    @Operation(summary = "Registrieren", description = "Erzeugt einen neuen Benutzer", security = {})
    public ResponseEntity<String> register(@Valid @RequestBody RegisterRequest req) {
        // Delegiere an Service, dort wird Validierung + Encoding durchgeführt
        UserEntity newUser = new UserEntity();
        newUser.setUsername(req.getUsername());
        // Rohes Passwort setzen; Service encodiert und setzt ROLE_USER
        newUser.setPassword(req.getPassword());

        authService.register(newUser);

        return ResponseEntity
                .created(URI.create("/api/users"))
                .body("✅ Benutzer erfolgreich registriert");
    }

    @PostMapping(value = "/login", consumes = "application/json", produces = "application/json")
    @Operation(summary = "Login", description = "Gibt JWT zurück", security = {})
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            LoginResponse loginResponse = authService.login(request);
            return ResponseEntity.ok(loginResponse);
        } catch (Exception e) {
            // Keine Details zum Grund (Timing-/User-Leak vermeiden)
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "❌ Login fehlgeschlagen"));
        }
    }
}
