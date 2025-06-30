import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AccountService } from '../../services/account.service';
import { AuthService } from '../../services/auth.service';
import { Account } from '../../models/account';
import { TransferRequest } from '../../models/transfer-request';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-account-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './account-list.component.html',
  styleUrls: ['./account-list.component.scss']
})
export class AccountListComponent implements OnInit, OnDestroy {
  accounts: Account[] = [];
  loading = false;
  error = '';

  // Create Account Form
  newAccount = {
    owner: '',
    balance: 0
  };
  createLoading = false;
  createMessage = '';

  // Transfer Form
  transferData = {
    fromAccountId: '',
    toAccountId: '',
    amount: ''
  };
  transferLoading = false;
  transferMessage = '';

  private subscriptions: Subscription[] = [];

  constructor(
    private accountService: AccountService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.loadAccounts();
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  loadAccounts(): void {
    this.loading = true;
    this.error = '';

    const sub = this.accountService.getAllAccounts().subscribe({
      next: (data) => {
        this.accounts = data;
        this.loading = false;
      },
      error: (error) => {
        this.error = error.message;
        this.loading = false;
        console.error('Error loading accounts:', error);
      }
    });

    this.subscriptions.push(sub);
  }

  createAccount(): void {
    if (!this.newAccount.owner.trim()) {
      this.createMessage = '❌ Bitte geben Sie einen Kontoinhaber an';
      return;
    }

    if (this.newAccount.balance < 0) {
      this.createMessage = '❌ Startguthaben darf nicht negativ sein';
      return;
    }

    this.createLoading = true;
    this.createMessage = '';

    const accountDto: Account = {
      owner: this.newAccount.owner.trim(),
      balance: this.newAccount.balance.toString()
    };

    const sub = this.accountService.createAccount(accountDto).subscribe({
      next: () => {
        this.createMessage = '✅ Konto wurde erfolgreich erstellt';
        this.newAccount = { owner: '', balance: 0 };
        this.createLoading = false;
        this.loadAccounts(); // Refresh list

        // Clear success message after 3 seconds
        setTimeout(() => this.createMessage = '', 3000);
      },
      error: (error) => {
        this.createMessage = `❌ ${error.message}`;
        this.createLoading = false;
      }
    });

    this.subscriptions.push(sub);
  }

  transfer(): void {
    const fromId = Number(this.transferData.fromAccountId);
    const toId = Number(this.transferData.toAccountId);
    const amount = Number(this.transferData.amount);

    // Validation
    if (isNaN(fromId) || isNaN(toId) || isNaN(amount)) {
      this.transferMessage = '❌ Bitte geben Sie gültige Zahlen ein';
      return;
    }

    if (fromId === toId) {
      this.transferMessage = '❌ Quell- und Zielkonto dürfen nicht identisch sein';
      return;
    }

    if (amount <= 0) {
      this.transferMessage = '❌ Betrag muss positiv sein';
      return;
    }

    // Check if accounts exist
    const fromAccount = this.accounts.find(acc => acc.id === fromId);
    const toAccount = this.accounts.find(acc => acc.id === toId);

    if (!fromAccount) {
      this.transferMessage = `❌ Quellkonto mit ID ${fromId} nicht gefunden`;
      return;
    }

    if (!toAccount) {
      this.transferMessage = `❌ Zielkonto mit ID ${toId} nicht gefunden`;
      return;
    }

    this.transferLoading = true;
    this.transferMessage = '';

    const transferRequest: TransferRequest = {
      fromAccountId: fromId,
      toAccountId: toId,
      amount: amount
    };

    const sub = this.accountService.transferMoney(transferRequest).subscribe({
      next: () => {
        this.transferMessage = '✅ Überweisung erfolgreich durchgeführt';
        this.transferData = { fromAccountId: '', toAccountId: '', amount: '' };
        this.transferLoading = false;
        this.loadAccounts(); // Refresh list

        // Clear success message after 3 seconds
        setTimeout(() => this.transferMessage = '', 3000);
      },
      error: (error) => {
        this.transferMessage = `❌ ${error.message}`;
        this.transferLoading = false;
      }
    });

    this.subscriptions.push(sub);
  }

  getCurrentUser(): string {
    const user = this.authService.getCurrentUser();
    return user ? user.username : 'Unbekannt';
  }

  formatBalance(balance: string | number): string {
    const num = typeof balance === 'string' ? parseFloat(balance) : balance;
    return new Intl.NumberFormat('de-DE', {
      style: 'currency',
      currency: 'EUR'
    }).format(num);
  }
}
