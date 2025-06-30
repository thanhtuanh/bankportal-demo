package com.example.bank;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/accounts")
@CrossOrigin(origins = "http://localhost:4200")
public class AccountController {

    private final AccountService accountService;

    public AccountController(AccountService accountService) {
        this.accountService = accountService;
    }

    @GetMapping
    public ResponseEntity<List<AccountDto>> getAll() {
        try {
            String currentUser = getCurrentUser();
            System.out.println("📋 User '" + currentUser + "' requesting all accounts");

            List<AccountDto> accounts = accountService.getAllAccounts();
            return ResponseEntity.ok(accounts);
        } catch (Exception e) {
            System.err.println("❌ Error getting accounts: " + e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping
    public ResponseEntity<AccountDto> create(@RequestBody AccountDto dto) {
        try {
            String currentUser = getCurrentUser();
            System.out.println("➕ User '" + currentUser + "' creating account for: " + dto.getOwner());

            AccountDto created = accountService.createAccount(dto);
            return ResponseEntity.ok(created);
        } catch (Exception e) {
            System.err.println("❌ Error creating account: " + e.getMessage());
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/transfer")
    public ResponseEntity<String> transfer(@RequestBody TransferRequest request) {
        try {
            String currentUser = getCurrentUser();
            System.out.println("💸 User '" + currentUser + "' initiating transfer: " +
                    request.getAmount() + "€ from " + request.getFromAccountId() +
                    " to " + request.getToAccountId());

            accountService.transfer(request);
            return ResponseEntity.ok("✅ Transfer successful");
        } catch (RuntimeException e) {
            System.err.println("❌ Transfer failed: " + e.getMessage());
            return ResponseEntity.badRequest().body("❌ " + e.getMessage());
        } catch (Exception e) {
            System.err.println("❌ Unexpected error during transfer: " + e.getMessage());
            return ResponseEntity.internalServerError().body("❌ Internal server error");
        }
    }

    private String getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null ? auth.getName() : "anonymous";
    }
}