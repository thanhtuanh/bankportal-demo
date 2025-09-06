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
import com.bankportal.authservice.repository.UserRepository;
import com.bankportal.authservice.service.AuthService;
import org.springframework.security.crypto.password.PasswordEncoder;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Benutzer-Authentifizierung und JWT-Token Management")
public class AuthController {

    private final AuthService authService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping(value = "/register", consumes = "application/json", produces = "text/plain")
    @Operation(summary = "Registrieren", description = "Erzeugt einen neuen Benutzer", security = {})
    public ResponseEntity<String> register(@Valid @RequestBody RegisterRequest req) {
        if (userRepository.existsByUsername(req.getUsername())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("❌ Benutzername bereits vergeben");
        }

        UserEntity u = new UserEntity();
        u.setUsername(req.getUsername());
        u.setPasswordHash(passwordEncoder.encode(req.getPassword()));
        u.setRole("USER"); // TODO: enum/constant ROLE_USER

        userRepository.save(u);

        // Optional: Location-Header / HATEOAS-light
        return ResponseEntity
                .created(URI.create("/api/users/" + u.getId()))
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
