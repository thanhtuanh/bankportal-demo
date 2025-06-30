// src/main/java/com/bankportal/authservice/service/AuthService.java
package com.bankportal.authservice.service;

import com.bankportal.authservice.dto.LoginRequest;
import com.bankportal.authservice.dto.LoginResponse;
import com.bankportal.authservice.model.UserEntity;
import com.bankportal.authservice.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public LoginResponse login(LoginRequest request) {
        UserEntity user = userRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> new BadCredentialsException("Benutzer nicht gefunden"));

        // 🔐 Passwort prüfen mit gespeichertem Hash
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BadCredentialsException("Ungültiges Passwort");
        }

        String token = jwtService.generateToken(user.getUsername());
        return new LoginResponse(token);
    }

    public UserEntity register(UserEntity newUser) {
        if (userRepository.findByUsername(newUser.getUsername()).isPresent()) {
            throw new BadCredentialsException("Benutzername bereits vergeben");
        }

        // 🔐 Passwort hashen und speichern
        String hashed = passwordEncoder.encode(newUser.getPassword());
        newUser.setPasswordHash(hashed);

        // ✅ Einheitliche Rolle setzen
        newUser.setRole("ROLE_USER");

        return userRepository.save(newUser);
    }
}
