// src/test/java/com/bankportal/accountservice/config/TestSecurityConfig.java
package com.bankportal.accountservice.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@TestConfiguration
public class TestSecurityConfig {
  @Bean
  SecurityFilterChain testSecurity(HttpSecurity http) throws Exception {
    return http.csrf(csrf -> csrf.disable())
              .authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
              .build();
  }
}
