import { Routes } from '@angular/router';
import { LoginComponent }    from './components/login/login.component';
import { RegisterComponent } from './components/register/register.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AuthGuard }         from './guards/auth.guard';

export const routes: Routes = [
  // 1) Wenn exakt '' (also http://localhost:4200) → weiter auf /login
  { path: '', redirectTo: 'login', pathMatch: 'full' },

  // 2) normalen Routes
  { path: 'login',    component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },

  // 3) Alles andere → Login (oder 404‑Seite, wenn  eine hast)
  { path: '**', redirectTo: 'login' }
];
