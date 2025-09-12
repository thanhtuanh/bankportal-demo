package com.bankportal.authservice.controller;

import com.bankportal.authservice.security.JwtFilter;
import com.bankportal.authservice.service.AuthService;
import com.bankportal.authservice.dto.LoginRequest;
import com.bankportal.authservice.dto.LoginResponse;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import com.bankportal.authservice.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;


import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

// Wichtig: JwtFilter (und ggf. SecurityConfig) aus dem Slice ausschließen
@WebMvcTest(
  controllers = AuthController.class,
  excludeFilters = @ComponentScan.Filter(
    type = FilterType.ASSIGNABLE_TYPE,
    classes = { JwtFilter.class } // ggf. zusätzlich SecurityConfig.class
  )
)
// Security-Filter (Spring Security) NICHT anwenden
@AutoConfigureMockMvc(addFilters = false)
class AuthControllerWebTest {

  @Autowired MockMvc mvc;

  // Controller hängt von AuthService ab -> mocken
  @MockBean AuthService authService;

  // Falls dein Controller direkt Repo/Encoder injiziert, hier auch mocken:
  @MockBean UserRepository userRepository;
  @MockBean PasswordEncoder passwordEncoder;

  @Test
  void login_ok() throws Exception {
    // stub Service-Antwort
    org.mockito.Mockito.when(authService.login(new LoginRequest("alice", "pw")))
        .thenReturn(new LoginResponse("test-token"));

    mvc.perform(post("/api/auth/login")
        .contentType(MediaType.APPLICATION_JSON)
        .content("{\"username\":\"alice\",\"password\":\"pw\"}"))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.token").exists());
  }

  @Test
  void register_ok() throws Exception {
    mvc.perform(post("/api/auth/register")
        .contentType(MediaType.APPLICATION_JSON)
        .content("{\"username\":\"bob\",\"password\":\"s3cret\"}"))
      .andExpect(status().isCreated());
  }
}
