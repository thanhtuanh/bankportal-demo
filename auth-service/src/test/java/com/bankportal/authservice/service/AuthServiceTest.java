// src/test/java/com/bankportal/authservice/service/AuthServiceTest.java
package com.bankportal.authservice.service;

import com.bankportal.authservice.dto.LoginRequest;
import com.bankportal.authservice.dto.LoginResponse;
import com.bankportal.authservice.model.UserEntity;
import com.bankportal.authservice.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.junit.jupiter.api.extension.ExtendWith;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    UserRepository repo = mock(UserRepository.class);
    PasswordEncoder encoder = mock(PasswordEncoder.class);
    JwtService jwt = mock(JwtService.class);
    AuthService service = new AuthService(repo, encoder, jwt);

    @Test
    void loginBenutzerNichtGefunden() {
        when(repo.findByUsername("u")).thenReturn(Optional.empty());
        assertThrows(BadCredentialsException.class,
                     () -> service.login(new LoginRequest("u", "p")));
    }

    @Test
    void loginFalschesPasswort() {
        UserEntity u = new UserEntity();
        u.setId(1L);
        u.setUsername("u");
        u.setPasswordHash("pw"); // angepasst
        u.setRole("ROLE_USER");
        when(repo.findByUsername("u")).thenReturn(Optional.of(u));
        when(encoder.matches("p", "pw")).thenReturn(false);

        assertThrows(BadCredentialsException.class,
                     () -> service.login(new LoginRequest("u", "p")));
    }

    @Test
    void loginErfolgreich() {
        UserEntity u = new UserEntity(1L, "u", "pw", "ROLE_USER");
        when(repo.findByUsername("u")).thenReturn(Optional.of(u));
        when(encoder.matches("p", "pw")).thenReturn(true);
        when(jwt.generateToken("u")).thenReturn("jwtToken");

        LoginResponse r = service.login(new LoginRequest("u", "p"));
        assertEquals("jwtToken", r.getToken());
    }

    @Test
    void registerErfolgreich() {
        UserEntity in = new UserEntity(null, "neuerUser", "plainPw", null);
        when(repo.findByUsername("neuerUser")).thenReturn(Optional.empty());
        when(encoder.encode("plainPw")).thenReturn("hashedPW");
        when(repo.save(any(UserEntity.class))).thenAnswer(inv -> {
            UserEntity saved = inv.getArgument(0);
            saved.setId(42L);
            return saved;
        });

        UserEntity out = service.register(in);
        assertEquals(42L, out.getId());
        assertEquals("neuerUser", out.getUsername());
        assertEquals("hashedPW", out.getPasswordHash()); // angepasst
        assertEquals("ROLE_USER", out.getRole());
    }

    @Test
    void registerExistiertBereits() {
        UserEntity existing = new UserEntity();
        existing.setId(1L);
        existing.setUsername("alice");
        existing.setPasswordHash("hash");
        existing.setRole("ROLE_USER");
        when(repo.findByUsername("alice")).thenReturn(Optional.of(existing));

        UserEntity newUser = new UserEntity();
        newUser.setUsername("alice");
        newUser.setPasswordHash("pw");
        assertThrows(BadCredentialsException.class,
                     () -> service.register(newUser));
    }
}
