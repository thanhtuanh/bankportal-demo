import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AccountService } from '../../services/account.service';
import { Account } from '../../models/account';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-account-create',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './account-create.component.html',
  styleUrls: ['./account-create.component.scss']
})
export class AccountCreateComponent {
  account: Account = { owner: '', balance: '0' };
  message = '';

  constructor(private accountService: AccountService) {}

  createAccount(): void {
    this.accountService.createAccount(this.account).subscribe(() => {
      this.message = '✅ Konto wurde erstellt';
    });
  }
}
