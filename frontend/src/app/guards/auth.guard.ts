import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {

  constructor(private authService: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
    console.log('🛡️ AuthGuard activated for URL:', state.url);
    
    // NOTFALL: Temporär ALLE Routen erlauben
    console.log('🔓 AuthGuard: Allowing all routes temporarily');
    return true;
    
    /* ORIGINAL CODE (AUSKOMMENTIERT für Debugging):
    if (this.authService.isLoggedIn()) {
      return true;
    } else {
      // NUR umleiten wenn es NICHT Login oder Register ist
      const currentUrl = state.url;
      if (currentUrl !== '/login' && currentUrl !== '/register') {
        this.router.navigate(['/login'], { queryParams: { returnUrl: state.url } });
      }
      return false;
    }
    */
  }
}
