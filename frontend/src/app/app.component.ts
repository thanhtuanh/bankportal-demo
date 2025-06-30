import { Component } from '@angular/core';
import { RouterOutlet, Router, NavigationStart, NavigationEnd, NavigationCancel, NavigationError } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  template: '<router-outlet></router-outlet>'
})
export class AppComponent {
  title = 'bank-portal';
  
  constructor(private router: Router) {
    console.log('🏠 AppComponent constructor started');
    
    // AGGRESSIVE Router Event Debugging
    this.router.events.subscribe(event => {
      console.log('🔍 Router Event Type:', event.constructor.name);
      
      if (event instanceof NavigationStart) {
        console.log('🚀 Navigation START to:', event.url);
        console.log('🧭 Navigation ID:', event.id);
        console.log('🔄 Navigation triggered by:', event.navigationTrigger);
      }
      if (event instanceof NavigationEnd) {
        console.log('✅ Navigation END to:', event.url);
        console.log('🎯 Final URL:', window.location.pathname);
      }
      if (event instanceof NavigationCancel) {
        console.log('❌ Navigation CANCEL:', event.reason);
        console.log('🔗 Cancelled URL:', event.url);
      }
      if (event instanceof NavigationError) {
        console.log('💥 Navigation ERROR:', event.error);
        console.log('🔗 Error URL:', event.url);
      }
    });
    
    // Überwachung von URL-Änderungen
    setInterval(() => {
      if (window.location.pathname !== '/login' && window.location.pathname !== '/register' && window.location.pathname !== '/dashboard') {
        console.log('⚠️ UNEXPECTED URL:', window.location.pathname);
      }
    }, 1000);
  }
}
