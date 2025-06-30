import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { RegisterComponent } from './components/register/register.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AuthGuard } from './guards/auth.guard';

export const routes: Routes = [
  // NOTFALL-LÖSUNG: Keine Redirects, nur direkte Routes
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },
  { path: '', component: LoginComponent }, // DIREKTER COMPONENT statt Redirect
  // Entfernt: { path: '**', redirectTo: '/login' } - Das verursacht Loops
];
