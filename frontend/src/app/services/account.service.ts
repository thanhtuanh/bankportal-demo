import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Account } from '../models/account';
import { TransferRequest } from '../models/transfer-request';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class AccountService {
  private apiUrl = 'http://localhost:8082/api/accounts';

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  private getHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': token ? `Bearer ${token}` : ''
    });
  }

  getAllAccounts(): Observable<Account[]> {
    console.log('Fetching accounts...');
    return this.http.get<Account[]>(this.apiUrl, { headers: this.getHeaders() })
      .pipe(
        catchError(this.handleError)
      );
  }

  createAccount(account: Account): Observable<Account> {
    console.log('Creating account:', account);
    return this.http.post<Account>(this.apiUrl, account, { headers: this.getHeaders() })
      .pipe(
        catchError(this.handleError)
      );
  }

  transferMoney(transfer: TransferRequest): Observable<string> {
    console.log('Transferring money:', transfer);
    // Expect text response instead of JSON
    return this.http.post(`${this.apiUrl}/transfer`, transfer, {
      headers: this.getHeaders(),
      responseType: 'text' // Accept text response
    })
    .pipe(
      catchError(this.handleError)
    );
  }

  private handleError(error: HttpErrorResponse) {
    console.error('Account Service Error:', error);
    let errorMessage = 'Ein unbekannter Fehler ist aufgetreten';

    if (error.status === 401 || error.status === 403) {
      errorMessage = 'Nicht autorisiert. Bitte melden Sie sich neu an.';
    } else if (error.error && typeof error.error === 'string') {
      errorMessage = error.error;
    } else if (error.error && error.error.message) {
      errorMessage = error.error.message;
    } else {
      errorMessage = `Server-Fehler: ${error.status}`;
    }

    return throwError(() => new Error(errorMessage));
  }
}
