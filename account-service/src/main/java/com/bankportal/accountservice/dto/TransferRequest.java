package com.bankportal.accountservice.dto;

public class TransferRequest {
    private Long fromAccountId;
    private Long toAccountId;
    private double amount;

    // Getter und Setter
    public Long getFromAccountId() { return fromAccountId; }
    public void setFromAccountId(Long fromAccountId) { this.fromAccountId = fromAccountId; }

    public Long getToAccountId() { return toAccountId; }
    public void setToAccountId(Long toAccountId) { this.toAccountId = toAccountId; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
}
