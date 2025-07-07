package com.bankportal.accountservice.dto;

import com.bankportal.accountservice.model.Account;

public class AccountDto {
    private Long id;
    private String owner;
    private double balance;

    public static AccountDto fromEntity(Account account) {
        AccountDto dto = new AccountDto();
        dto.setId(account.getId());
        dto.setOwner(account.getOwner());
        dto.setBalance(account.getBalance());
        return dto;
    }

    // Getter und Setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getOwner() { return owner; }
    public void setOwner(String owner) { this.owner = owner; }

    public double getBalance() { return balance; }
    public void setBalance(double balance) { this.balance = balance; }
}
