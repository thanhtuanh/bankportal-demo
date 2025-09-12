package com.bankportal.authservice.controller;

import com.bankportal.authservice.security.JwtUtil;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;
import com.bankportal.authservice.security.JwtFilter;


import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(
  controllers = ValidationController.class,
  excludeFilters = @ComponentScan.Filter(
    type = FilterType.ASSIGNABLE_TYPE,
    classes = { JwtFilter.class }
  )
)
@AutoConfigureMockMvc(addFilters = false)
class ValidationControllerWebTest {

    @Autowired
    MockMvc mvc;

    @MockBean
    JwtUtil jwtUtil;

    @Test
    void validate_missingToken() throws Exception {
        mvc.perform(get("/api/auth/validate"))
           .andExpect(status().isUnauthorized())
           .andExpect(header().string("X-Auth-Status", "missing_token"));
    }

    @Test
    void validate_invalidToken() throws Exception {
        when(jwtUtil.isTokenValid("bad")).thenReturn(false);

        mvc.perform(get("/api/auth/validate")
                .header("Authorization", "Bearer bad"))
           .andExpect(status().isUnauthorized())
           .andExpect(header().string("X-Auth-Status", "invalid"));
    }

    @Test
    void validate_ok() throws Exception {
        when(jwtUtil.isTokenValid("good")).thenReturn(true);
        when(jwtUtil.extractUsername("good")).thenReturn("alice");

        mvc.perform(get("/api/auth/validate")
                .header("Authorization", "Bearer good")
                .header("X-Original-URI", "/api/account/me"))
           .andExpect(status().isOk())
           .andExpect(header().string("X-Auth-Status", "valid"))
           .andExpect(header().string("X-User", "alice"))
           .andExpect(jsonPath("$.valid").value(true))
           .andExpect(jsonPath("$.username").value("alice"))
           .andExpect(jsonPath("$.original_uri").value("/api/account/me"));
    }
}
