# 🏦 Bank Portal

Eine moderne Mikroservice-basierte Banking-Anwendung mit Angular Frontend und Spring Boot Backend.

## 📋 Inhaltsverzeichnis

- [Überblick](#überblick)
- [Architektur](#architektur)
- [Technologie-Stack](#technologie-stack)
- [Installation & Setup](#installation--setup)
- [Konfiguration](#konfiguration)
- [API Dokumentation](#api-dokumentation)
- [Frontend Features](#frontend-features)
- [Security](#security)
- [Tests](#tests)
- [Troubleshooting](#troubleshooting)

## 🎯 Überblick

Das Bank Portal ist eine vollständige Banking-Anwendung mit folgenden Hauptfunktionen:

- **Benutzerregistrierung und -anmeldung**
- **Kontoverwaltung** (Konten erstellen, anzeigen)
- **Geldtransfers** zwischen Konten
- **JWT-basierte Authentifizierung**
- **Responsive Angular Frontend**
- **Mikroservice-Architektur**

## 🏗️ Architektur

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│  Angular SPA    │───►│  Auth Service   │    │ Account Service │
│  (Port 4200)    │    │  (Port 8081)    │    │  (Port 8082)    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │ PostgreSQL      │    │ PostgreSQL      │
                       │ (Auth DB)       │    │ (Account DB)    │
                       │ Port 5432       │    │ Port 5433       │
                       └─────────────────┘    └─────────────────┘
```

### Services

1. **Frontend (Angular)**
   - Single Page Application
   - Responsive Design
   - JWT Token Management
   - Route Guards

2. **Auth Service (Spring Boot)**
   - Benutzerregistrierung
   - Login/Logout
   - JWT Token Generation
   - Passwort Hashing (BCrypt)

3. **Account Service (Spring Boot)**
   - Kontoverwaltung
   - Geldtransfers
   - Geschäftslogik
   - JWT Token Validation

## 🛠️ Technologie-Stack

### Frontend
- **Angular 18+** - Framework
- **TypeScript** - Programmiersprache
- **SCSS** - Styling
- **RxJS** - Reactive Programming
- **Angular Router** - Navigation
- **HTTP Client** - API Kommunikation

### Backend
- **Spring Boot 3.x** - Framework
- **Spring Security** - Sicherheit
- **Spring Data JPA** - Datenzugriff
- **PostgreSQL** - Datenbank
- **JWT** - Token-basierte Authentifizierung
- **BCrypt** - Passwort Hashing
- **Lombok** - Code Generation

### Tools & Testing
- **JUnit 5** - Testing Framework
- **Mockito** - Mocking Framework
- **Maven** - Build Tool
- **Docker** - Containerisierung

## 🚀 Installation & Setup

### Voraussetzungen

- **Node.js** (v18+)
- **Angular CLI** (`npm install -g @angular/cli`)
- **Java 17+**
- **Maven 3.6+**
- **PostgreSQL 13+** oder Docker

### 1. Repository Klonen

```bash
git clone <repository-url>
cd bank-portal
```

### 2. Datenbank Setup

#### Option A: Docker (Empfohlen)

```bash
# Auth Service Database
docker run --name postgres-auth -e POSTGRES_DB=authdb -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -p 5432:5432 -d postgres:13

# Account Service Database  
docker run --name postgres-account -e POSTGRES_DB=accountdb -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -p 5433:5432 -d postgres:13
```

#### Option B: Lokale PostgreSQL Installation

```sql
-- Auth Database
CREATE DATABASE authdb;
CREATE USER admin WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE authdb TO admin;

-- Account Database
CREATE DATABASE accountdb;
GRANT ALL PRIVILEGES ON DATABASE accountdb TO admin;
```

### 3. Backend Services Starten

#### Auth Service

```bash
cd auth-service
mvn clean install
mvn spring-boot:run
```

Der Auth Service läuft auf: `http://localhost:8081`

#### Account Service

```bash
cd account-service
mvn clean install
mvn spring-boot:run
```

Der Account Service läuft auf: `http://localhost:8082`

### 4. Frontend Starten

```bash
cd frontend
npm install
ng serve
```

Das Frontend läuft auf: `http://localhost:4200`

## ⚙️ Konfiguration

### Environment Variables

```bash
# JWT Secret (muss in beiden Services identisch sein)
export JWT_SECRET=mysecretkeymysecretkeymysecretkey123456

# Database URLs
export AUTH_DB_URL=jdbc:postgresql://localhost:5432/authdb
export ACCOUNT_DB_URL=jdbc:postgresql://localhost:5433/accountdb
```

### Application Properties

#### Auth Service (`application.properties`)

```properties
server.port=8081
spring.datasource.url=jdbc:postgresql://localhost:5432/authdb
spring.datasource.username=admin
spring.datasource.password=admin
jwt.secret=${JWT_SECRET:mysecretkeymysecretkeymysecretkey123456}
jwt.expiration-ms=86400000
```

#### Account Service (`application.properties`)

```properties
server.port=8082
spring.datasource.url=jdbc:postgresql://localhost:5433/accountdb
spring.datasource.username=admin
spring.datasource.password=admin
jwt.secret=${JWT_SECRET:mysecretkeymysecretkeymysecretkey123456}
```

## 📡 API Dokumentation

### Auth Service APIs

#### POST `/api/auth/register`
Registriert einen neuen Benutzer.

**Request Body:**
```json
{
  "username": "testuser",
  "password": "password123"
}
```

**Response:** `201 Created`
```json
{
  "message": "✅ Benutzer erfolgreich registriert"
}
```

#### POST `/api/auth/login`
Meldet einen Benutzer an.

**Request Body:**
```json
{
  "username": "testuser", 
  "password": "password123"
}
```

**Response:** `200 OK`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Account Service APIs

> **Hinweis:** Alle Account Service APIs benötigen den `Authorization: Bearer <token>` Header.

#### GET `/api/accounts`
Gibt alle Konten zurück.

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "owner": "Max Mustermann",
    "balance": 1000.50
  }
]
```

#### POST `/api/accounts`
Erstellt ein neues Konto.

**Request Body:**
```json
{
  "owner": "Anna Schmidt",
  "balance": 500.00
}
```

**Response:** `200 OK`
```json
{
  "id": 2,
  "owner": "Anna Schmidt", 
  "balance": 500.00
}
```

#### POST `/api/accounts/transfer`
Überweist Geld zwischen Konten.

**Request Body:**
```json
{
  "fromAccountId": 1,
  "toAccountId": 2,
  "amount": 100.00
}
```

**Response:** `200 OK`
```text
✅ Transfer successful
```

## 🎨 Frontend Features

### Komponenten

1. **LoginComponent** - Benutzeranmeldung
2. **RegisterComponent** - Benutzerregistrierung  
3. **DashboardComponent** - Hauptansicht
4. **AccountListComponent** - Kontenübersicht und -verwaltung
5. **NavigationComponent** - Navigation und Logout

### Services

1. **AuthService** - Authentifizierung und Token Management
2. **AccountService** - Kontoverwaltung und Transfers
3. **AuthGuard** - Route Protection

### Interceptors

- **AuthInterceptor** - Automatisches Hinzufügen von JWT Tokens

### Features

- ✅ Responsive Design
- ✅ Echtzeit-Validierung
- ✅ Loading States
- ✅ Error Handling
- ✅ Success/Error Nachrichten
- ✅ Currency Formatting (EUR)
- ✅ Automatischer Logout bei Token-Expiry
- ✅ Deutsche Lokalisierung

## 🔒 Security

### Implementierte Sicherheitsmaßnahmen

1. **JWT Tokens**
   - Stateless Authentication
   - Configurable Expiration (24h default)
   - HMAC-SHA256 Signing

2. **Password Security**
   - BCrypt Hashing (Salted)
   - Minimum Length Validation

3. **API Security**
   - All Account APIs protected
   - Token Validation on each request
   - Automatic logout on 401 errors

4. **CORS Configuration**
   - Configured for localhost:4200
   - Controlled access headers

5. **Input Validation**
   - Frontend form validation
   - Backend DTO validation
   - SQL Injection prevention (JPA)

### Security Headers

```http
Authorization: Bearer <jwt-token>
Content-Type: application/json
```

## 🧪 Tests

### Backend Tests ausführen

```bash
# Auth Service Tests
cd auth-service
mvn test

# Account Service Tests  
cd account-service
mvn test
```

### Test Coverage

#### Auth Service Tests
- ✅ `loginBenutzerNichtGefunden()`
- ✅ `loginFalschesPasswort()`
- ✅ `loginErfolgreich()`
- ✅ `registerErfolgreich()`
- ✅ `registerExistiertBereits()`

#### Account Service Tests
- ✅ `testGetAllAccounts()`
- ✅ `testCreateAccount()`
- ✅ `testTransferThrowsIfAccountNotFound()`
- ✅ `testTransferThrowsIfNotEnoughMoney()`

### Frontend Tests

```bash
cd frontend
npm test
```

## 🐛 Troubleshooting

### Häufige Probleme

#### 1. "Connection refused" Fehler

**Problem:** Frontend kann Backend nicht erreichen

**Lösung:**
```bash
# Prüfen ob Services laufen
netstat -tlnp | grep 8081  # Auth Service
netstat -tlnp | grep 8082  # Account Service

# Services neu starten
mvn spring-boot:run
```

#### 2. JWT Token Fehler

**Problem:** "Invalid or expired token"

**Lösung:**
- Logout und erneut anmelden
- JWT Secret in beiden Services prüfen
- Token Expiration prüfen

#### 3. Datenbank Connection Fehler

**Problem:** "Connection to database failed"

**Lösung:**
```bash
# PostgreSQL Status prüfen
sudo systemctl status postgresql

# Docker Container prüfen
docker ps | grep postgres

# Connection testen
psql -h localhost -p 5432 -U admin -d authdb
```

#### 4. CORS Fehler

**Problem:** "Access to fetch blocked by CORS policy"

**Lösung:**
- CORS Konfiguration in `SecurityConfig.java` prüfen
- Frontend URL in `allowedOrigins` korrekt setzen

#### 5. Port Konflikte

**Problem:** "Port already in use"

**Lösung:**
```bash
# Prozess auf Port finden und beenden
lsof -ti:8081 | xargs kill -9
lsof -ti:8082 | xargs kill -9
lsof -ti:4200 | xargs kill -9
```

### Logs

#### Backend Logs anzeigen

```bash
# Mit Maven
mvn spring-boot:run | grep -E "(ERROR|WARN|INFO)"

# Application Logs
tail -f logs/application.log
```

#### Frontend Logs

Browser Developer Tools → Console

### Debug Mode

```bash
# Backend mit Debug
mvn spring-boot:run -Dspring.profiles.active=debug

# Frontend mit Debug
ng serve --verbose
```

## 📝 Code-Struktur

### Frontend (`/frontend`)

```
src/
├── app/
│   ├── components/          # UI Komponenten
│   │   ├── login/
│   │   ├── register/
│   │   ├── dashboard/
│   │   ├── account-list/
│   │   └── navigation/
│   ├── services/           # Business Logic
│   │   ├── auth.service.ts
│   │   └── account.service.ts
│   ├── models/             # TypeScript Interfaces
│   ├── guards/             # Route Guards
│   ├── interceptors/       # HTTP Interceptors
│   └── app.routes.ts       # Routing Configuration
├── styles.scss             # Global Styles
└── index.html
```

### Backend Auth Service (`/auth-service`)

```
src/main/java/com/bankportal/authservice/
├── controller/             # REST Controllers
├── service/               # Business Logic
├── repository/            # Data Access
├── model/                 # JPA Entities
├── dto/                   # Data Transfer Objects
├── security/              # Security Configuration
└── config/                # Application Configuration
```

### Backend Account Service (`/account-service`)

```
src/main/java/com/example/bank/
├── AccountController.java      # REST Controller
├── AccountService.java         # Business Logic
├── AccountRepository.java      # Data Access
├── Account.java               # JPA Entity
├── AccountDto.java            # Data Transfer Object
├── TransferRequest.java       # Transfer DTO
├── SecurityConfig.java        # Security & JWT
└── GlobalExceptionHandler.java # Error Handling
```

## 🚀 Deployment

### Production Build

#### Frontend
```bash
cd frontend
ng build --configuration production
```

#### Backend
```bash
# Auth Service
cd auth-service
mvn clean package -Pprod

# Account Service  
cd account-service
mvn clean package -Pprod
```

### Docker Deployment

```dockerfile
# Beispiel Dockerfile für Backend
FROM openjdk:17-jre-slim
COPY target/auth-service-*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

## 📄 Lizenz

Dieses Projekt ist unter der MIT Lizenz veröffentlicht.

## 🤝 Beitragen

1. Fork das Repository
2. Erstelle einen Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Committe deine Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

## 📞 Support

Bei Fragen oder Problemen erstellen Sie bitte ein Issue im Repository.

---

**Version:** 1.0.0  
**Letztes Update:** Dezember 2024