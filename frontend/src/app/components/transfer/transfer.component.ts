import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AccountService } from '../../services/account.service';
import { TransferRequest } from '../../models/transfer-request';

@Component({
  selector: 'app-transfer',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './transfer.component.html',
  styleUrls: ['./transfer.component.scss']
})
export class TransferComponent {
  transferData = {
    fromAccountId: '',
    toAccountId: '',
    amount: ''
  };

  message = '';

  constructor(private accountService: AccountService) {}

  submitTransfer() {
    const dto: TransferRequest = {
      fromAccountId: Number(this.transferData.fromAccountId),
      toAccountId: Number(this.transferData.toAccountId),
      amount: Number(this.transferData.amount)
    };

    if (isNaN(dto.fromAccountId) || isNaN(dto.toAccountId) || isNaN(dto.amount)) {
      this.message = '❌ Ungültige Eingabe – bitte nur Zahlen verwenden.';
      return;
    }

    this.accountService.transferMoney(dto).subscribe({
      next: () => {
        this.message = '✅ Überweisung erfolgreich!';
        this.transferData = { fromAccountId: '', toAccountId: '', amount: '' };
      },
      error: () => {
        this.message = '❌ Überweisung fehlgeschlagen!';
      }
    });
  }
}
