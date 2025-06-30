#!/bin/bash
# ===== FIX ROUTING PROBLEM =====

# ./frontend/fix-routing.sh
#!/bin/bash

echo "🔧 Fixing Angular Routing Problem..."

# 1. Check current routes
echo "📝 Current app.routes.ts:"
cat src/app/app.routes.ts

echo ""
echo "🔧 Fixing routes configuration..."

# 2. Fix app.routes.ts - ensure RegisterComponent is properly imported
cat > src/app/app.routes.ts << 'EOF'
import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { RegisterComponent } from './components/register/register.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AuthGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },
  { path: '**', redirectTo: '/login' }
];
EOF

# 3. Check if RegisterComponent exists and is properly defined
echo "📝 Checking RegisterComponent..."
if [ ! -f "src/app/components/register/register.component.ts" ]; then
    echo "❌ RegisterComponent not found! Creating it..."
    
    mkdir -p src/app/components/register
    
    cat > src/app/components/register/register.component.ts << 'EOF'
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
EOF

    cat > src/app/components/register/register.component.html << 'EOF'
<div class="auth-container">
  <div class="auth-card">
    <h2>🏦 Bank Portal - Registrierung</h2>
    
    <form (ngSubmit)="onRegister()" #registerForm="ngForm">
      <div class="form-group">
        <label for="username">Benutzername:</label>
        <input 
          type="text" 
          id="username"
          [(ngModel)]="userData.username" 
          name="username"
          placeholder="Benutzername wählen"
          required
          minlength="3">
      </div>

      <div class="form-group">
        <label for="password">Passwort:</label>
        <input 
          type="password" 
          id="password"
          [(ngModel)]="userData.password" 
          name="password"
          placeholder="Passwort eingeben"
          required
          minlength="4">
      </div>

      <div class="form-group">
        <label for="confirmPassword">Passwort bestätigen:</label>
        <input 
          type="password" 
          id="confirmPassword"
          [(ngModel)]="confirmPassword" 
          name="confirmPassword"
          placeholder="Passwort wiederholen"
          required>
      </div>

      <div *ngIf="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>

      <div *ngIf="successMessage" class="success-message">
        {{ successMessage }}
      </div>

      <button 
        type="submit" 
        [disabled]="registerForm.invalid || isLoading"
        class="btn btn-primary">
        <span *ngIf="isLoading">⏳ Wird registriert...</span>
        <span *ngIf="!isLoading">✅ Registrieren</span>
      </button>
    </form>

    <div class="auth-footer">
      <p>Bereits ein Konto? 
        <a href="#" (click)="goToLogin()">Hier anmelden</a>
      </p>
    </div>
  </div>
</div>
EOF

    cat > src/app/components/register/register.component.scss << 'EOF'
.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.auth-card {
  background: white;
  padding: 2rem;
  border-radius: 10px;
  box-shadow: 0 10px 25px rgba(0,0,0,0.2);
  width: 100%;
  max-width: 400px;
}

.auth-card h2 {
  text-align: center;
  margin-bottom: 1.5rem;
  color: #333;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
  color: #555;
}

.form-group input {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #ddd;
  border-radius: 5px;
  font-size: 1rem;
  transition: border-color 0.3s;
  box-sizing: border-box;
}

.form-group input:focus {
  outline: none;
  border-color: #007bff;
}

.error-message {
  background: #f8d7da;
  color: #721c24;
  padding: 0.75rem;
  border-radius: 5px;
  margin-bottom: 1rem;
  border: 1px solid #f5c6cb;
}

.success-message {
  background: #d4edda;
  color: #155724;
  padding: 0.75rem;
  border-radius: 5px;
  margin-bottom: 1rem;
  border: 1px solid #c3e6cb;
}

.btn {
  width: 100%;
  padding: 0.75rem;
  border: none;
  border-radius: 5px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.3s;
}

.btn-primary {
  background-color: #007bff;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background-color: #0056b3;
}

.btn:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
}

.auth-footer {
  text-align: center;
  margin-top: 1.5rem;
}

.auth-footer a {
  color: #007bff;
  text-decoration: none;
  cursor: pointer;
}

.auth-footer a:hover {
  text-decoration: underline;
}
EOF

    echo "✅ RegisterComponent created!"
else
    echo "✅ RegisterComponent exists"
fi

# 4. Fix AuthGuard - ensure it doesn't interfere with register route
echo "📝 Checking AuthGuard..."
cat > src/app/guards/auth.guard.ts << 'EOF'
import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
    console.log('AuthGuard: Checking route', state.url);
    
    // Allow public routes
    if (state.url === '/login' || state.url === '/register') {
      return true;
    }
    
    if (this.authService.isLoggedIn()) {
      console.log('AuthGuard: User is logged in');
      return true;
    } else {
      console.log('AuthGuard: User not logged in, redirecting to login');
      this.router.navigate(['/login'], { queryParams: { returnUrl: state.url } });
      return false;
    }
  }
}
EOF

# 5. Add debugging to app component
echo "📝 Adding routing debugging..."
cat > src/app/app.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { RouterOutlet } from '@angular/router';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  template: '<router-outlet></router-outlet>'
})
export class AppComponent implements OnInit {
  title = 'bank-portal';

  constructor(private router: Router) {}

  ngOnInit() {
    // Debug routing
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe((event: NavigationEnd) => {
      console.log('Navigation to:', event.urlAfterRedirects);
    });
  }
}
EOF

echo "✅ Routing fixes applied!"
echo ""
echo "🚀 Now restart the development server:"
echo "   npm start"
echo ""
echo "🧪 Test URLs:"
echo "   http://localhost:4200/login"
echo "   http://localhost:4200/register"
echo ""
echo "📝 Check browser console for routing debug messages"