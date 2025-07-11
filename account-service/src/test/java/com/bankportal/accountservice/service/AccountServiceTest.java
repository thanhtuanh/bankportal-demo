package com.bankportal.accountservice.service;

import com.bankportal.accountservice.repository.AccountRepository;
import com.bankportal.accountservice.model.Account;
import com.bankportal.accountservice.dto.AccountDto;
import com.bankportal.accountservice.dto.TransferRequest;
import org.junit.jupiter.api.Test;
import java.util.Optional;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class AccountServiceTest {

    AccountRepository repo = mock(AccountRepository.class);
    AccountService service = new AccountService(repo);

    @Test
    void testGetAllAccounts() {
        Account acc = new Account(); 
        acc.setOwner("Max"); 
        acc.setBalance(100);
        
        when(repo.findAll()).thenReturn(Arrays.asList(acc));
        List<AccountDto> result = service.getAllAccounts();
        
        assertEquals(1, result.size());
        assertEquals("Max", result.get(0).getOwner());
    }

    @Test
    void testCreateAccount() {
        AccountDto dto = new AccountDto(); 
        dto.setOwner("Anna"); 
        dto.setBalance(200);
        
        Account acc = new Account(); 
        acc.setId(1L);
        acc.setOwner("Anna"); 
        acc.setBalance(200);
        
        when(repo.save(any())).thenReturn(acc);
        AccountDto created = service.createAccount(dto);
        
        assertEquals("Anna", created.getOwner());
        assertEquals(200, created.getBalance());
    }

    @Test
    void testTransferThrowsIfAccountNotFound() {
        TransferRequest req = new TransferRequest();
        req.setFromAccountId(1L);
        req.setToAccountId(2L);
        req.setAmount(100);
        
        // Mock: fromAccount nicht gefunden
        when(repo.findById(1L)).thenReturn(Optional.empty());
        
        Exception ex = assertThrows(RuntimeException.class, () -> service.transfer(req));
        assertTrue(ex.getMessage().contains("Senderkonto nicht gefunden"));
    }

    @Test
    void testTransferThrowsIfNotEnoughMoney() {
        Account sender = new Account(); 
        sender.setId(1L); 
        sender.setBalance(50);
        
        Account receiver = new Account(); 
        receiver.setId(2L); 
        receiver.setBalance(0);
        
        TransferRequest req = new TransferRequest();
        req.setFromAccountId(1L);
        req.setToAccountId(2L);
        req.setAmount(100);

        when(repo.findById(1L)).thenReturn(Optional.of(sender));
        when(repo.findById(2L)).thenReturn(Optional.of(receiver));

        Exception ex = assertThrows(RuntimeException.class, () -> service.transfer(req));
        assertTrue(ex.getMessage().contains("Nicht genügend Guthaben"));
    }
}
