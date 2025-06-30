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
    // Clear previous messages
    this.errorMessage = '';
    this.successMessage = '';

    // Validation
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

    if (this.userData.username.length < 3) {
      this.errorMessage = 'Benutzername muss mindestens 3 Zeichen lang sein';
      return;
    }

    this.isLoading = true;

    // Clean data before sending
    const cleanUserData: RegisterRequest = {
      username: this.userData.username.trim(),
      password: this.userData.password.trim()
    };

    console.log('Registering user:', cleanUserData.username);

    this.authService.register(cleanUserData).subscribe({
      next: (response) => {
        console.log('Registration successful:', response);
        this.isLoading = false;
        this.successMessage = 'Registrierung erfolgreich! Sie können sich jetzt anmelden.';

        // Clear form
        this.userData = { username: '', password: '' };
        this.confirmPassword = '';

        // Redirect after delay
        setTimeout(() => {
          this.router.navigate(['/login']);
        }, 2000);
      },
      error: (error) => {
        console.error('Registration error:', error);
        this.isLoading = false;
        this.errorMessage = error.message || 'Registrierung fehlgeschlagen';
      }
    });
  }

  goToLogin(): void {
    this.router.navigate(['/login']);
  }
}
