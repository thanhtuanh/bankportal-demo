package com.bankportal.accountservice.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.bankportal.accountservice.dto.AccountDto;
import com.bankportal.accountservice.dto.TransferRequest;
import com.bankportal.accountservice.service.AccountService;

@RestController
@RequestMapping("/api/accounts")
@CrossOrigin(origins = "http://localhost:4200")
public class AccountController {

    private static final Logger logger = LoggerFactory.getLogger(AccountController.class);

    private final AccountService accountService;

    public AccountController(AccountService accountService) {
        this.accountService = accountService;
    }

    @GetMapping
    public ResponseEntity<List<AccountDto>> getAll() {
        try {
            String currentUser = getCurrentUser();
            logger.info("📋 User '{}' requesting all accounts", currentUser);

            List<AccountDto> accounts = accountService.getAllAccounts();
            logger.debug("✅ Retrieved {} accounts for user '{}'", accounts.size(), currentUser);
            return ResponseEntity.ok(accounts);
        } catch (Exception e) {
            logger.error("❌ Error getting accounts for user '{}': {}", getCurrentUser(), e.getMessage(), e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping
    public ResponseEntity<AccountDto> create(@RequestBody AccountDto dto) {
        try {
            String currentUser = getCurrentUser();
            logger.info("➕ User '{}' creating account for: {}", currentUser, dto.getOwner());

            AccountDto created = accountService.createAccount(dto);
            logger.info("✅ Account successfully created with ID {} for owner '{}' by user '{}'",
                    created.getId(), created.getOwner(), currentUser);
            return ResponseEntity.ok(created);
        } catch (RuntimeException e) {
            logger.warn("❌ Account creation failed for user '{}': {}", getCurrentUser(), e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("❌ Unexpected error creating account for user '{}': {}", getCurrentUser(), e.getMessage(), e);
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/transfer")
    public ResponseEntity<String> transfer(@RequestBody TransferRequest request) {
        String currentUser = getCurrentUser();

        try {
            logger.info("💸 User '{}' initiating transfer: {}€ from account {} to account {}",
                    currentUser, request.getAmount(), request.getFromAccountId(), request.getToAccountId());

            accountService.transfer(request);

            logger.info("✅ Transfer successful: {}€ from account {} to account {} by user '{}'",
                    request.getAmount(), request.getFromAccountId(), request.getToAccountId(), currentUser);
            return ResponseEntity.ok("✅ Transfer successful");

        } catch (RuntimeException e) {
            logger.warn("❌ Transfer failed for user '{}': {}", currentUser, e.getMessage());
            return ResponseEntity.badRequest().body("❌ " + e.getMessage());
        } catch (Exception e) {
            logger.error("❌ Unexpected error during transfer for user '{}': {}", currentUser, e.getMessage(), e);
            return ResponseEntity.internalServerError().body("❌ Internal server error");
        }
    }

    private String getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null ? auth.getName() : "anonymous";
    }
}