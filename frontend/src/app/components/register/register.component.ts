import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormsModule, NgForm } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { RegisterRequest } from '../../models/auth';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [RouterModule, CommonModule, FormsModule],
  template: `
    <div class="register-container">
      <div class="register-form">
        <div class="register-header">
          <h2>Konto erstellen</h2>
          <p>Erstellen Sie Ihr kostenloses Bank Portal Konto</p>
        </div>

        <form #registerForm="ngForm" (ngSubmit)="onRegister(registerForm)" novalidate>
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
              maxlength="20"
              #usernameField="ngModel"
              class="form-control"
              [class.error]="usernameField.invalid && usernameField.touched"
              placeholder="Benutzername wählen">
            <div *ngIf="usernameField.invalid && usernameField.touched" class="field-error">
              <span *ngIf="usernameField.errors?.['required']">Benutzername ist erforderlich</span>
              <span *ngIf="usernameField.errors?.['minlength']">Mindestens 3 Zeichen erforderlich</span>
              <span *ngIf="usernameField.errors?.['maxlength']">Maximal 20 Zeichen erlaubt</span>
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
              placeholder="Sicheres Passwort wählen">
            <div *ngIf="passwordField.invalid && passwordField.touched" class="field-error">
              <span *ngIf="passwordField.errors?.['required']">Passwort ist erforderlich</span>
              <span *ngIf="passwordField.errors?.['minlength']">Mindestens 6 Zeichen erforderlich</span>
            </div>
          </div>

          <div class="form-group">
            <label for="confirmPassword">Passwort bestätigen</label>
            <input
              type="password"
              id="confirmPassword"
              name="confirmPassword"
              [(ngModel)]="confirmPassword"
              (input)="onInputChange()"
              required
              #confirmPasswordField="ngModel"
              class="form-control"
              [class.error]="confirmPasswordField.touched && password !== confirmPassword"
              placeholder="Passwort wiederholen">
            <div *ngIf="confirmPasswordField.touched && password !== confirmPassword" class="field-error">
              Passwörter stimmen nicht überein
            </div>
          </div>

          <button
            type="submit"
            [disabled]="registerForm.invalid || password !== confirmPassword || isLoading"
            class="register-btn">
            <span *ngIf="!isLoading">Konto erstellen</span>
            <span *ngIf="isLoading" class="loading-spinner">
              <i class="spinner"></i>
              Konto wird erstellt...
            </span>
          </button>
        </form>

        <div *ngIf="errorMessage" class="error-message">
          <strong>Registrierung fehlgeschlagen</strong>
          <p>{{ errorMessage }}</p>
        </div>

        <div *ngIf="successMessage" class="success-message">
          <strong>Erfolgreich registriert!</strong>
          <p>{{ successMessage }}</p>
        </div>

        <div class="login-section">
          <p>Bereits ein Konto?</p>
          <a routerLink="/login" class="login-btn-link">Jetzt anmelden</a>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .register-container {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 1rem;
    }

    .register-form {
      background: white;
      padding: 2rem;
      border-radius: 8px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      width: 100%;
      max-width: 400px;
    }

    .register-header {
      text-align: center;
      margin-bottom: 2rem;
    }

    .register-header h2 {
      margin: 0 0 0.5rem 0;
      color: #1f2937;
      font-size: 1.5rem;
      font-weight: 700;
    }

    .register-header p {
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

    .register-btn {
      width: 100%;
      padding: 0.75rem;
      background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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

    .register-btn:hover:not(:disabled) {
      transform: translateY(-1px);
      box-shadow: 0 4px 8px rgba(16, 185, 129, 0.3);
    }

    .register-btn:disabled {
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

    .login-section {
      text-align: center;
      padding-top: 1rem;
      border-top: 1px solid #e5e7eb;
    }

    .login-section p {
      margin: 0 0 0.5rem 0;
      color: #6b7280;
      font-size: 0.875rem;
    }

    .login-btn-link {
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

    .login-btn-link:hover {
      background: #e5e7eb;
      text-decoration: none;
    }

    @media (max-width: 480px) {
      .register-form {
        margin: 1rem;
        padding: 1.5rem;
      }
      
      .register-header h2 {
        font-size: 1.25rem;
      }
    }
  `]
})
export class RegisterComponent {
  username: string = '';
  password: string = '';
  confirmPassword: string = '';
  errorMessage: string = '';
  successMessage: string = '';
  isLoading: boolean = false;

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  onRegister(form: NgForm) {
    if (form.valid && this.password === this.confirmPassword) {
      this.isLoading = true;
      this.errorMessage = '';
      this.successMessage = '';

      const userData: RegisterRequest = {
        username: this.username.trim(),
        password: this.password
      };

      console.log('Registering user:', userData.username);

      this.authService.register(userData).subscribe({
        next: (response) => {
          console.log('✅ Registration successful:', response);
          this.isLoading = false;
          
          if (response.success) {
            this.successMessage = response.message || 'Registrierung erfolgreich!';
            setTimeout(() => {
              this.router.navigate(['/login']);
            }, 2000);
          }
        },
        error: (error) => {
          console.log('❌ Registration failed:', error);
          this.isLoading = false;
          this.errorMessage = error.message || 'Registrierung fehlgeschlagen';
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
