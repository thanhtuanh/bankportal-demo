package com.bankportal.authservice.service;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class JwtServiceTest {

    JwtService jwtService = new JwtService();

    @Test
    void generateAndValidateToken() {
        String token = jwtService.generateToken("alice");
        assertNotNull(token);
        assertTrue(jwtService.isTokenValid(token));
        assertEquals("alice", jwtService.extractUsername(token));
    }

    @Test
    void invalidToken() {
        String token = "invalid.jwt.token";
        assertFalse(jwtService.isTokenValid(token));
    }
}
