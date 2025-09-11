// src/test/java/com/bankportal/accountservice/it/AccountServiceIntegrationTest.java
package com.bankportal.accountservice.it;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.*;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Instant;
import java.util.Date;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@Testcontainers
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class AccountServiceIntegrationTest {

  @Container
  static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

  @DynamicPropertySource
  static void props(DynamicPropertyRegistry r) {
    r.add("spring.datasource.url", postgres::getJdbcUrl);
    r.add("spring.datasource.username", postgres::getUsername);
    r.add("spring.datasource.password", postgres::getPassword);
    r.add("spring.jpa.hibernate.ddl-auto", () -> "update");
    // wichtig: dieselbe Secret-Quelle wie produktiv (Property oder env),
    // SecurityConfig nutzt hartes Secret – daher hier identisch setzen:
    r.add("jwt.secret", () -> "mysecretkeymysecretkeymysecretkey123456");
  }

  @LocalServerPort int port;
  @Autowired TestRestTemplate rest;
  ObjectMapper om = new ObjectMapper();

  private String bearer() {
    // Gleiches Secret wie SecurityConfig (siehe Code) -> Token gültig. 
    Key key = Keys.hmacShaKeyFor("mysecretkeymysecretkeymysecretkey123456".getBytes(StandardCharsets.UTF_8));
    var now = Instant.now();
    var token = Jwts.builder()
        .subject("itest-user")
        .issuedAt(Date.from(now))
        .expiration(Date.from(now.plusSeconds(3600)))
        .signWith(key)
        .compact();
    return "Bearer " + token;
  }

  private HttpHeaders jsonAuth() {
    var h = new HttpHeaders();
    h.setContentType(MediaType.APPLICATION_JSON);
    h.set(HttpHeaders.AUTHORIZATION, bearer());
    return h;
  }

  @Test
  void create_then_list_then_transfer_flow() throws Exception {
    String base = "http://localhost:"+port;

    // 1) Konto anlegen
    var req1 = new HttpEntity<>("""
        {"owner":"Alice","balance":1000.0}
      """, jsonAuth());
    var created = rest.exchange(base + "/api/accounts", HttpMethod.POST, req1, String.class);
    assertThat(created.getStatusCode().is2xxSuccessful()).isTrue();

    // 2) 2. Konto anlegen
    var req2 = new HttpEntity<>("""
        {"owner":"Bob","balance":100.0}
      """, jsonAuth());
    var created2 = rest.exchange(base + "/api/accounts", HttpMethod.POST, req2, String.class);
    assertThat(created2.getStatusCode().is2xxSuccessful()).isTrue();

    // 3) Liste abrufen
    var listResp = rest.exchange(base + "/api/accounts", HttpMethod.GET, new HttpEntity<>(jsonAuth()), String.class);
    assertThat(listResp.getStatusCode().is2xxSuccessful()).isTrue();
    List<Map<String,Object>> accounts = om.readValue(listResp.getBody(), new TypeReference<>() {});
    assertThat(accounts).extracting(m -> (String)m.get("owner")).contains("Alice","Bob");

    // IDs herausziehen
    Long aliceId = ((Number) accounts.stream().filter(m->"Alice".equals(m.get("owner"))).findFirst().get().get("id")).longValue();
    Long bobId   = ((Number) accounts.stream().filter(m->"Bob".equals(m.get("owner"))).findFirst().get().get("id")).longValue();

    // 4) Transfer 200 von Alice -> Bob
    var transfer = new HttpEntity<>(("""
        {"fromAccountId":%d,"toAccountId":%d,"amount":200.0}
      """).formatted(aliceId,bobId), jsonAuth());
    var tResp = rest.exchange(base + "/api/accounts/transfer", HttpMethod.POST, transfer, String.class);
    assertThat(tResp.getStatusCode().is2xxSuccessful()).isTrue();
    assertThat(tResp.getBody()).contains("✅");

    // 5) Nochmal Liste prüfen: Salden plausibel (Alice 800, Bob 300)
    var list2 = rest.exchange(base + "/api/accounts", HttpMethod.GET, new HttpEntity<>(jsonAuth()), String.class);
    List<Map<String,Object>> after = om.readValue(list2.getBody(), new TypeReference<>() {});
    double aliceBal = ((Number) after.stream().filter(m->"Alice".equals(m.get("owner"))).findFirst().get().get("balance")).doubleValue();
    double bobBal   = ((Number) after.stream().filter(m->"Bob".equals(m.get("owner"))).findFirst().get().get("balance")).doubleValue();
    assertThat(aliceBal).isEqualTo(800.0);
    assertThat(bobBal).isEqualTo(300.0);
  }
}
