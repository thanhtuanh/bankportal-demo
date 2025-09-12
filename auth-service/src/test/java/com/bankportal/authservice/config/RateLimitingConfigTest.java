package com.bankportal.authservice.config;

import org.junit.jupiter.api.Test;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class RateLimitingConfigTest {

  @RestController
  static class DummyLoginController {
    @GetMapping("/api/auth/login")
    public String ok() { return "OK"; }
  }

  @Test
  void exceedingLimitReturns429() throws Exception {
    var interceptor = new RateLimitingConfig.RateLimitingInterceptor();

    MockMvc mvc = MockMvcBuilders
      .standaloneSetup(new DummyLoginController())
      .addInterceptors(interceptor)
      .build();

    for (int i = 0; i < 5; i++) {
      mvc.perform(get("/api/auth/login")).andExpect(status().isOk());
    }
    mvc.perform(get("/api/auth/login")).andExpect(status().isTooManyRequests());
  }
}
