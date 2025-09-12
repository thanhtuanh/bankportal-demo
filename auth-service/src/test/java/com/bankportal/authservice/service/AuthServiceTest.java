package com.bankportal.authservice.service;

import com.bankportal.authservice.dto.LoginRequest;
import com.bankportal.authservice.dto.LoginResponse;
import com.bankportal.authservice.model.UserEntity;
import com.bankportal.authservice.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    UserRepository repo = mock(UserRepository.class);
    PasswordEncoder encoder = mock(PasswordEncoder.class);
    JwtService jwt = mock(JwtService.class);
    AuthService service = new AuthService(repo, encoder, jwt);

    @Test
    void loginBenutzerNichtGefunden() {
        when(repo.findByUsername("u")).thenReturn(Optional.empty());

        BadCredentialsException ex = assertThrows(
            BadCredentialsException.class,
            () -> service.login(new LoginRequest("u", "p"))
        );
        assertTrue(ex.getMessage().toLowerCase().contains("nicht gefunden"));
        verify(repo).findByUsername("u");
        verifyNoMoreInteractions(repo, encoder, jwt);
    }

    @Test
    void loginFalschesPasswort() {
        UserEntity u = new UserEntity(1L, "u", "hash", "ROLE_USER");
        when(repo.findByUsername("u")).thenReturn(Optional.of(u));
        when(encoder.matches("p", "hash")).thenReturn(false);

        BadCredentialsException ex = assertThrows(
            BadCredentialsException.class,
            () -> service.login(new LoginRequest("u", "p"))
        );
        assertTrue(ex.getMessage().toLowerCase().contains("ungültig"));
        verify(repo).findByUsername("u");
        verify(encoder).matches("p", "hash");
        verifyNoMoreInteractions(repo, encoder);
        verifyNoInteractions(jwt);
    }

    @Test
    void loginErfolgreich() {
        UserEntity u = new UserEntity(1L, "u", "hash", "ROLE_USER");
        when(repo.findByUsername("u")).thenReturn(Optional.of(u));
        when(encoder.matches("p", "hash")).thenReturn(true);
        when(jwt.generateToken("u")).thenReturn("jwtToken");

        LoginResponse r = service.login(new LoginRequest("u", "p"));
        assertEquals("jwtToken", r.getToken());

        verify(repo).findByUsername("u");
        verify(encoder).matches("p", "hash");
        verify(jwt).generateToken("u");
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
        assertEquals("hashedPW", out.getPasswordHash());
        assertEquals("ROLE_USER", out.getRole());

        verify(repo).findByUsername("neuerUser");
        verify(encoder).encode("plainPw");
        verify(repo).save(any(UserEntity.class));
    }

    @ParameterizedTest
    @CsvSource({
        "alice, alice",    // gleicher Name
        "bob, bob"         // gleicher Name
    })
    void registerExistiertBereits(String existingName, String newName) {
        UserEntity existing = new UserEntity(1L, existingName, "hash", "ROLE_USER");
        when(repo.findByUsername(existingName)).thenReturn(Optional.of(existing));

        UserEntity newUser = new UserEntity(null, newName, "pw", null);
        assertThrows(BadCredentialsException.class, () -> service.register(newUser));
        verify(repo).findByUsername(existingName);
        verifyNoInteractions(encoder);
        verify(repo, never()).save(any());
    }
}
