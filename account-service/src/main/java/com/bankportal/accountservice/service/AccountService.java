package com.bankportal.accountservice.service;

import com.bankportal.accountservice.repository.AccountRepository;
import com.bankportal.accountservice.model.Account;
import com.bankportal.accountservice.dto.AccountDto;
import com.bankportal.accountservice.dto.TransferRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class AccountService {

  private final AccountRepository accountRepository;

  public AccountService(AccountRepository accountRepository) {
    this.accountRepository = accountRepository;
  }

  public List<AccountDto> getAllAccounts() {
    String currentUser = getCurrentUser();
    System.out.println("🔍 Getting all accounts for user: " + currentUser);

    return accountRepository.findAll().stream()
        .map(AccountDto::fromEntity)
        .collect(Collectors.toList());
  }

  public AccountDto createAccount(AccountDto dto) {
    String currentUser = getCurrentUser();
    System.out.println("➕ Creating account for owner: " + dto.getOwner() + " by user: " + currentUser);

    // Validation
    if (dto.getOwner() == null || dto.getOwner().trim().isEmpty()) {
      throw new RuntimeException("Kontoinhaber darf nicht leer sein");
    }

    if (dto.getBalance() < 0) {
      throw new RuntimeException("Startguthaben darf nicht negativ sein");
    }

    Account account = new Account();
    account.setOwner(dto.getOwner().trim());
    account.setBalance(dto.getBalance());

    account = accountRepository.save(account);
    System.out.println("✅ Account created with ID: " + account.getId());

    return AccountDto.fromEntity(account);
  }

  @Transactional
  public void transfer(TransferRequest request) {
    String currentUser = getCurrentUser();
    System.out.println("💸 Processing transfer by user: " + currentUser);

    // Validation
    if (request.getFromAccountId().equals(request.getToAccountId())) {
      throw new RuntimeException("Quell- und Zielkonto dürfen nicht identisch sein");
    }

    if (request.getAmount() <= 0) {
      throw new RuntimeException("Betrag muss positiv sein");
    }

    // WICHTIG: Die genauen Fehlermeldungen die der Test erwartet
    Account from = accountRepository.findById(request.getFromAccountId())
        .orElseThrow(() -> new RuntimeException("Senderkonto nicht gefunden"));

    Account to = accountRepository.findById(request.getToAccountId())
        .orElseThrow(() -> new RuntimeException("Empfängerkonto nicht gefunden"));

    if (from.getBalance() < request.getAmount()) {
      throw new RuntimeException("Nicht genügend Guthaben. Verfügbar: " +
          from.getBalance() + "€, Benötigt: " + request.getAmount() + "€");
    }

    // Perform transfer
    double newFromBalance = from.getBalance() - request.getAmount();
    double newToBalance = to.getBalance() + request.getAmount();

    from.setBalance(newFromBalance);
    to.setBalance(newToBalance);

    accountRepository.save(from);
    accountRepository.save(to);

    System.out.println("✅ Transfer completed: " + request.getAmount() + "€ from account " +
        request.getFromAccountId() + " to account " + request.getToAccountId());
  }

  private String getCurrentUser() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    return auth != null ? auth.getName() : "system";
  }
}
