import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/auth.service';
import { RegisterRequest } from '../../models/auth';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [FormsModule, CommonModule],
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss']
})
export class RegisterComponent {
  userData: RegisterRequest = {
    username: '',
    password: ''
  };
  
  confirmPassword = '';
  errorMessage = '';
  successMessage = '';
  isLoading = false;

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  onRegister(): void {
    if (!this.userData.username || !this.userData.password || !this.confirmPassword) {
      this.errorMessage = 'Bitte alle Felder ausfüllen';
      return;
    }

    if (this.userData.password !== this.confirmPassword) {
      this.errorMessage = 'Passwörter stimmen nicht überein';
      return;
    }

    if (this.userData.password.length < 4) {
      this.errorMessage = 'Passwort muss mindestens 4 Zeichen lang sein';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    this.authService.register(this.userData).subscribe({
      next: () => {
        this.isLoading = false;
        this.successMessage = 'Registrierung erfolgreich! Sie können sich jetzt anmelden.';
        setTimeout(() => {
          this.router.navigate(['/login']);
        }, 2000);
      },
      error: (error) => {
        this.isLoading = false;
        this.errorMessage = error.message || 'Registrierung fehlgeschlagen';
      }
    });
  }

  goToLogin(): void {
    this.router.navigate(['/login']);
  }
}
