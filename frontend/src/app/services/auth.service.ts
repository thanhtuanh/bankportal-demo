import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { BehaviorSubject, Observable, throwError, of } from 'rxjs';
import { tap, catchError, map } from 'rxjs/operators';
import { LoginRequest, LoginResponse, RegisterRequest, User } from '../models/auth';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'http://localhost:8081/api/auth'; // Direct URL for local test
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(private http: HttpClient) {
    this.checkExistingToken();
  }

  login(credentials: LoginRequest): Observable<LoginResponse> {
    console.log('Sending login request:', credentials);
    return this.http.post<LoginResponse>(`${this.apiUrl}/login`, credentials)
      .pipe(
        tap(response => {
          console.log('Login successful:', response);
          this.setToken(response.token);
          this.setCurrentUser(credentials.username);
        }),
        catchError(this.handleError)
      );
  }

  register(userData: RegisterRequest): Observable<any> {
    console.log('Sending register request:', userData);

    // Ensure clean data structure
    const cleanData = {
      username: userData.username.trim(),
      password: userData.password
    };

    console.log('Clean register data:', cleanData);

    return this.http.post(`${this.apiUrl}/register`, cleanData, {
      responseType: 'text', // WICHTIG: Text statt JSON erwarten
      observe: 'response'   // Komplette HTTP Response mit Status Code
    }).pipe(
      tap(response => {
        console.log('Registration response:', response);
        console.log('Status Code:', response.status);
        console.log('Response Body:', response.body);
      }),
      // Response in standardisiertes Format umwandeln
      map((response: any) => {
        if (response.status === 201 || response.status === 200) {
          return {
            success: true,
            message: response.body || 'Registrierung erfolgreich'
          };
        }
        throw new Error(`Unerwarteter Status: ${response.status}`);
      }),
      catchError((error: HttpErrorResponse) => {
        console.log('Registration error details:', error);
        
        // HTTP 201 ist ERFOLG, nicht Fehler!
        if (error.status === 201) {
          console.log('✅ Registration successful (Status 201 caught as error)');
          return of({
            success: true,
            message: error.error || 'Registrierung erfolgreich'
          });
        }
        
        return this.handleError(error);
      })
    );
  }

  logout(): void {
    localStorage.removeItem('token');
    localStorage.removeItem('username');
    this.currentUserSubject.next(null);
  }

  getToken(): string | null {
    return localStorage.getItem('token');
  }

  isLoggedIn(): boolean {
    const token = this.getToken();
    if (!token) return false;

    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const currentTime = Math.floor(Date.now() / 1000);
      return payload.exp > currentTime;
    } catch (error) {
      return false;
    }
  }

  getCurrentUser(): User | null {
    return this.currentUserSubject.value;
  }

  private setToken(token: string): void {
    localStorage.setItem('token', token);
  }

  private setCurrentUser(username: string): void {
    const user: User = { username };
    localStorage.setItem('username', username);
    this.currentUserSubject.next(user);
  }

  private checkExistingToken(): void {
    const token = this.getToken();
    const username = localStorage.getItem('username');
    if (token && username && this.isLoggedIn()) {
      this.setCurrentUser(username);
    } else {
      this.logout();
    }
  }

  private handleError(error: HttpErrorResponse) {
    console.error('HTTP Error:', error);

    let errorMessage = 'Ein unbekannter Fehler ist aufgetreten';

    if (error.error instanceof ErrorEvent) {
      errorMessage = `Fehler: ${error.error.message}`;
    } else {
      if (error.status === 401) {
        errorMessage = 'Ungültige Anmeldedaten';
      } else if (error.status === 409) {
        errorMessage = 'Benutzername bereits vergeben';
      } else if (error.error && typeof error.error === 'string') {
        errorMessage = error.error;
      } else if (error.error && error.error.error) {
        errorMessage = error.error.error;
      } else {
        errorMessage = `Server-Fehler: ${error.status}`;
      }
    }

    return throwError(() => new Error(errorMessage));
  }
}
