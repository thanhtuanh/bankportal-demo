package com.bankportal.accountservice.controller;

import com.bankportal.accountservice.dto.AccountDto;
import com.bankportal.accountservice.dto.TransferRequest;
import com.bankportal.accountservice.service.AccountService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.ComponentScan.Filter;
import org.springframework.context.annotation.FilterType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ActiveProfiles("test")

// 1) Nur den Controller als Kontext definieren – NICHT die App-Klasse:
@ContextConfiguration(classes = { AccountController.class })

// 2) Reiner MVC-Slice:
@WebMvcTest(
    controllers = AccountController.class,
    // Falls du eigene Config-Klassen für JPA hast, hier herausfiltern:
    excludeFilters = {
        @Filter(type = FilterType.REGEX, pattern = ".*Jpa.*"),
        @Filter(type = FilterType.REGEX, pattern = ".*Persistence.*"),
        @Filter(type = FilterType.REGEX, pattern = ".*Database.*")
    }
)

// 3) JPA-/DB-Autoconfigs HART ausschließen:
@ImportAutoConfiguration(exclude = {
    DataSourceAutoConfiguration.class,
    HibernateJpaAutoConfiguration.class,
    JpaRepositoriesAutoConfiguration.class
})

@AutoConfigureMockMvc(addFilters = false)
class AccountControllerWebMvcTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper objectMapper;

    // Service wird gemockt – keine Repos/JPA nötig
    @MockBean AccountService accountService;

    @Test
    void getAll_returns200AndList() throws Exception {
        var a = new AccountDto();
        a.setId(1L); a.setOwner("Max"); a.setBalance(100.0);

        Mockito.when(accountService.getAllAccounts()).thenReturn(List.of(a));

        mvc.perform(get("/api/accounts"))
           .andExpect(status().isOk())
           .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
           .andExpect(jsonPath("$[0].id").value(1))
           .andExpect(jsonPath("$[0].owner").value("Max"))
           .andExpect(jsonPath("$[0].balance").value(100.0));
    }

    @Test
    void create_returns200AndCreatedDto() throws Exception {
        var payload = new AccountDto(); payload.setOwner("Anna"); payload.setBalance(200.0);
        var created = new AccountDto(); created.setId(99L); created.setOwner("Anna"); created.setBalance(200.0);

        Mockito.when(accountService.createAccount(any(AccountDto.class))).thenReturn(created);

        mvc.perform(post("/api/accounts")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(payload)))
           .andExpect(status().isOk())
           .andExpect(jsonPath("$.id").value(99))
           .andExpect(jsonPath("$.owner").value("Anna"))
           .andExpect(jsonPath("$.balance").value(200.0));
    }

    @Test
    void transfer_returns200OnSuccess() throws Exception {
        var req = new TransferRequest();
        req.setFromAccountId(1L); req.setToAccountId(2L); req.setAmount(80.0);

        mvc.perform(post("/api/accounts/transfer")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
           .andExpect(status().isOk())
           .andExpect(content().string(Matchers.containsString("✅"))); // ggf. anpassen
    }
}
