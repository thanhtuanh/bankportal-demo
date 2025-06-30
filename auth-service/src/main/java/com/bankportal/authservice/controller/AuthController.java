// src/main/java/com/bankportal/authservice/controller/AuthController.java
package com.bankportal.authservice.controller;

import com.bankportal.authservice.model.UserEntity;
import com.bankportal.authservice.service.AuthService;
import com.bankportal.authservice.dto.LoginRequest;
import com.bankportal.authservice.dto.LoginResponse;
import lombok.RequiredArgsConstructor;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final com.bankportal.authservice.repository.UserRepository userRepository;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody UserEntity user) {
        System.out.println("➡️ Registrierungsversuch für Benutzer: " + user.getUsername());
        try {
            if (userRepository.findByUsername(user.getUsername()).isPresent()) {
                return ResponseEntity.status(HttpStatus.CONFLICT)
                        .body("❌ Benutzername bereits vergeben");
            }

            // 👉 Passwort wird als Hash gespeichert
            user.setPasswordHash(passwordEncoder.encode(user.getPassword()));
            user.setRole("USER"); // oder "ROLE_USER", je nach Security-Konzept
            userRepository.save(user);

            System.out.println("✅ Benutzer erfolgreich registriert: " + user.getUsername());
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body("✅ Benutzer erfolgreich registriert");

        } catch (DataIntegrityViolationException ex) {
            System.err.println("❌ Datenbankfehler bei Registrierung: " + ex.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("❌ Benutzername existiert bereits (DB-Constraint)");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("❌ Unerwarteter Fehler: " + e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse loginResponse = authService.login(request);
            return ResponseEntity.ok(loginResponse);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "❌ Login fehlgeschlagen: " + e.getMessage()));
        }
    }
}
