import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormsModule, NgForm } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { LoginRequest } from '../../models/auth';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [RouterModule, CommonModule, FormsModule],
  template: `
    <div class="login-container">
      <div class="login-form">
        <div class="login-header">
          <h2>Bank Portal</h2>
          <p>Anmelden um fortzufahren</p>
        </div>
        
        <form #loginForm="ngForm" (ngSubmit)="onLogin(loginForm)" novalidate>
          <div class="form-group">
            <label for="username">Benutzername</label>
            <input 
              type="text" 
              id="username" 
              name="username"
              [(ngModel)]="username"
              (input)="onInputChange()"
              required
              minlength="3"
              #usernameField="ngModel"
              class="form-control"
              [class.error]="usernameField.invalid && usernameField.touched"
              placeholder="Benutzername eingeben">
            <div *ngIf="usernameField.invalid && usernameField.touched" class="field-error">
              <span *ngIf="usernameField.errors?.['required']">Benutzername ist erforderlich</span>
              <span *ngIf="usernameField.errors?.['minlength']">Mindestens 3 Zeichen erforderlich</span>
            </div>
          </div>

          <div class="form-group">
            <label for="password">Passwort</label>
            <input 
              type="password" 
              id="password" 
              name="password"
              [(ngModel)]="password"
              (input)="onInputChange()"
              required
              minlength="6"
              #passwordField="ngModel"
              class="form-control"
              [class.error]="passwordField.invalid && passwordField.touched"
              placeholder="Passwort eingeben">
            <div *ngIf="passwordField.invalid && passwordField.touched" class="field-error">
              <span *ngIf="passwordField.errors?.['required']">Passwort ist erforderlich</span>
              <span *ngIf="passwordField.errors?.['minlength']">Mindestens 6 Zeichen erforderlich</span>
            </div>
          </div>

          <button 
            type="submit" 
            [disabled]="loginForm.invalid || isLoading"
            class="login-btn">
            <span *ngIf="!isLoading">Anmelden</span>
            <span *ngIf="isLoading" class="loading-spinner">
              <i class="spinner"></i>
              Anmeldung läuft...
            </span>
          </button>
        </form>

        <div *ngIf="errorMessage" class="error-message">
          <strong>Anmeldung fehlgeschlagen</strong>
          <p>{{ errorMessage }}</p>
        </div>

        <div *ngIf="successMessage" class="success-message">
          <strong>Erfolgreich</strong>
          <p>{{ successMessage }}</p>
        </div>

        <div class="register-section">
          <p>Noch kein Konto?</p>
          <a routerLink="/register" class="register-btn">Kostenloses Konto erstellen</a>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .login-container {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 1rem;
    }

    .login-form {
      background: white;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      width: 100%;
      max-width: 400px;
    }

    .login-header {
      text-align: center;
      margin-bottom: 2rem;
    }

    .login-header h2 {
      margin: 0 0 0.5rem 0;
      color: #1f2937;
      font-size: 1.5rem;
      font-weight: 700;
    }

    .login-header p {
      margin: 0;
      color: #6b7280;
      font-size: 0.875rem;
    }

    .form-group {
      margin-bottom: 1rem;
    }

    label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 600;
      color: #374151;
      font-size: 0.875rem;
    }

    .form-control {
      width: 100%;
      padding: 0.75rem;
      border: 2px solid #e5e7eb;
      border-radius: 6px;
      font-size: 1rem;
      transition: border-color 0.2s;
      box-sizing: border-box;
    }

    .form-control:focus {
      outline: none;
      border-color: #3b82f6;
    }

    .form-control.error {
      border-color: #ef4444;
    }

    .field-error {
      margin-top: 0.25rem;
      color: #ef4444;
      font-size: 0.75rem;
    }

    .login-btn {
      width: 100%;
      padding: 0.75rem;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      margin-bottom: 1rem;
      min-height: 44px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
    }

    .login-btn:hover:not(:disabled) {
      transform: translateY(-1px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
    }

    .login-btn:disabled {
      background: #9ca3af;
      cursor: not-allowed;
      transform: none;
      box-shadow: none;
    }

    .loading-spinner {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .spinner {
      width: 16px;
      height: 16px;
      border: 2px solid transparent;
      border-top: 2px solid white;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    .error-message {
      background: #fef2f2;
      border: 1px solid #fecaca;
      border-radius: 6px;
      padding: 1rem;
      margin-bottom: 1rem;
    }

    .error-message strong {
      color: #dc2626;
      display: block;
      margin-bottom: 0.25rem;
      font-size: 0.875rem;
    }

    .error-message p {
      color: #7f1d1d;
      margin: 0;
      font-size: 0.875rem;
    }

    .success-message {
      background: #f0fdf4;
      border: 1px solid #bbf7d0;
      border-radius: 6px;
      padding: 1rem;
      margin-bottom: 1rem;
    }

    .success-message strong {
      color: #166534;
      display: block;
      margin-bottom: 0.25rem;
      font-size: 0.875rem;
    }

    .success-message p {
      color: #14532d;
      margin: 0;
      font-size: 0.875rem;
    }

    .register-section {
      text-align: center;
      padding-top: 1rem;
      border-top: 1px solid #e5e7eb;
    }

    .register-section p {
      margin: 0 0 0.5rem 0;
      color: #6b7280;
      font-size: 0.875rem;
    }

    .register-btn {
      display: inline-block;
      padding: 0.5rem 1rem;
      background: #f3f4f6;
      color: #374151;
      text-decoration: none;
      border-radius: 6px;
      font-weight: 600;
      font-size: 0.875rem;
      transition: all 0.2s;
    }

    .register-btn:hover {
      background: #e5e7eb;
      text-decoration: none;
    }

    @media (max-width: 480px) {
      .login-form {
        margin: 1rem;
        padding: 1.5rem;
      }
      
      .login-header h2 {
        font-size: 1.25rem;
      }
    }
  `]
})
export class LoginComponent {
  username = '';
  password = '';
  errorMessage = '';
  successMessage = '';
  isLoading = false;

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  onLogin(form: NgForm) {
    if (form.valid) {
      this.isLoading = true;
      this.errorMessage = '';
      this.successMessage = '';

      const credentials: LoginRequest = {
        username: this.username.trim(),
        password: this.password
      };

      this.authService.login(credentials).subscribe({
        next: () => {
          console.log('✅ Login successful');
          this.isLoading = false;
          this.successMessage = 'Anmeldung erfolgreich! Weiterleitung...';
          
          setTimeout(() => {
            this.router.navigate(['/dashboard']);
          }, 1000);
        },
        error: (error) => {
          console.log('❌ Login failed:', error);
          this.isLoading = false;
          this.errorMessage = error.message || 'Anmeldung fehlgeschlagen';
          
          if (this.errorMessage.includes('falsch')) {
            this.password = '';
          }
        }
      });
    } else {
      this.errorMessage = 'Bitte füllen Sie alle Felder korrekt aus.';
    }
  }

  onInputChange() {
    if (this.errorMessage) {
      this.errorMessage = '';
    }
    if (this.successMessage) {
      this.successMessage = '';
    }
  }
}
