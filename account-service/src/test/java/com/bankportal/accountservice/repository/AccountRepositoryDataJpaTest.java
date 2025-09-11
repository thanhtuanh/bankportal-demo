// src/test/java/com/bankportal/accountservice/repository/AccountRepositoryDataJpaTest.java
package com.bankportal.accountservice.repository;

import com.bankportal.accountservice.model.Account;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;

@Testcontainers
@DataJpaTest
class AccountRepositoryDataJpaTest {

  @Container
  static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

  @DynamicPropertySource
  static void props(DynamicPropertyRegistry r) {
    r.add("spring.datasource.url", postgres::getJdbcUrl);
    r.add("spring.datasource.username", postgres::getUsername);
    r.add("spring.datasource.password", postgres::getPassword);
    r.add("spring.jpa.hibernate.ddl-auto", () -> "update");
  }

  @Autowired AccountRepository repo;

  @Test
  void saveAndFind_roundtrip() {
    var a = new Account();
    a.setOwner("Max"); a.setBalance(123.45);
    var saved = repo.save(a);

    assertThat(saved.getId()).isNotNull();
    assertThat(repo.findById(saved.getId())).isPresent();
  }
}
