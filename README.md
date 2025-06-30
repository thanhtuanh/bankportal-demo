# 🏦 Bank Portal – Eine zukunftssichere Finanzanwendung

Eine **moderne, mikroservice-basierte Banking-Plattform** mit einem responsiven Angular Frontend und einem robusten Spring Boot Backend, speziell entwickelt, um die hohen Anforderungen der Finanzbranche an **Sicherheit, Skalierbarkeit und Zuverlässigkeit** zu erfüllen.

-----

## 🎯 Überblick & Relevanz für die Bankenbranche

Das **Bank Portal** ist eine vollständige Banking-Anwendung, die **Kernfunktionen eines modernen Finanzinstituts** abbildet und dabei höchsten Wert auf **Sicherheit, Datenintegrität und Benutzerfreundlichkeit** legt. Dieses Projekt demonstriert meine Fähigkeit, komplexe **Softwarelösungen für regulierte Umfelder** zu entwickeln, die den Anforderungen an eine ausfallsichere und performante Bankensoftware gerecht werden.

**Hauptfunktionen:**

  - **Sichere Benutzerregistrierung und -anmeldung:** Umfassendes Authentifizierungs- und Autorisierungssystem.
  - **Robuste Kontoverwaltung:** Zuverlässige Erstellung, Anzeige und Verwaltung von Bankkonten.
  - **Auditierbare Geldtransfers:** Sichere und nachvollziehbare Transaktionen zwischen Konten.
  - **JWT-basierte Authentifizierung:** Standardkonforme und skalierbare Sicherheitsmechanismen.
  - **Responsives Angular Frontend:** Intuitive und zugängliche Benutzeroberfläche für verschiedene Endgeräte.
  - **Mikroservice-Architektur:** Ermöglicht flexible Skalierung und einfache Wartung der einzelnen Geschäftsbereiche.

-----

## 🏗️ Architektur & Skalierbarkeit

Die Anwendung ist in einer **modernen Mikroservice-Architektur** aufgebaut, die **Agilität, Skalierbarkeit und Resilienz** fördert – entscheidende Faktoren für die dynamische Bankenlandschaft. Die klare Trennung von Verantwortlichkeiten (Auth- und Account-Services) minimiert Abhängigkeiten und ermöglicht eine unabhängige Entwicklung und Bereitstellung.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│   Angular SPA   │────►│   Auth Service  │     │ Account Service │
│   (Port 4200)   │     │   (Port 8081)   │     │   (Port 8082)   │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │                       │
                              ▼                       ▼
                      ┌─────────────────┐     ┌─────────────────┐
                      │   PostgreSQL    │     │   PostgreSQL    │
                      │   (Auth DB)     │     │ (Account DB)    │
                      │   Port 5432     │     │ Port 5433       │
                      └─────────────────┘     └─────────────────┘
```

### Services & Verantwortlichkeiten:

1.  **Frontend (Angular):**
      * **User Experience (UX):** Single Page Application mit responsivem Design für eine nahtlose Benutzerführung.
      * **Sichere Client-Seite:** JWT Token Management und Route Guards zum Schutz sensibler Bereiche.
      * **Effiziente Kommunikation:** HTTP Client für die performante Interaktion mit den Backend-Services.
2.  **Auth Service (Spring Boot):**
      * **Identitätsmanagement:** Sichere Benutzerregistrierung und Login/Logout-Funktionalität.
      * **Token-Ausstellung:** Robuste JWT Token Generation für authentifizierte Sitzungen.
      * **Passwort-Sicherheit:** Industriestandard BCrypt Hashing für den Schutz von Benutzerpasswörtern.
3.  **Account Service (Spring Boot):**
      * **Kern-Finanzlogik:** Verwaltung von Konten und Abwicklung von Geldtransfers.
      * **Geschäftslogik-Implementierung:** Kapselung komplexer Bankprozesse.
      * **Autorisierung:** JWT Token Validation zur Sicherstellung berechtigter Zugriffe auf Finanzdaten.

-----

## 🛠️ Technologie-Stack – Bewährte Enterprise-Technologien

Dieses Projekt nutzt einen modernen und branchenüblichen Technologie-Stack, der für **Stabilität, Performance und langfristige Wartbarkeit** in Unternehmensumgebungen, insbesondere im Bankensektor, konzipiert ist.

### Frontend

  - **Angular 18+:** Führendes Framework für komplexe Single Page Applications, ideal für interaktive Finanzportale.
  - **TypeScript:** Typsichere Entwicklung für robusten und wartbaren Frontend-Code.
  - **SCSS:** Effizientes Styling für ein konsistentes und responsives Design.
  - **RxJS:** Reactive Programming für die Handhabung asynchroner Datenströme, essenziell für Echtzeit-Updates.
  - **Angular Router:** Umfassendes Navigationssystem mit Schutzmechanismen (Guards).
  - **HTTP Client:** Standard für die sichere und effiziente API-Kommunikation.

### Backend

  - **Spring Boot 3.x:** De-facto-Standard für Java-Backend-Entwicklung in der Enterprise-Welt, bekannt für Produktivität und Stabilität.
  - **Spring Security:** Umfassendes Sicherheitsframework für Authentifizierung und Autorisierung.
  - **Spring Data JPA:** Effizienter und sicherer Datenzugriff auf relationale Datenbanken.
  - **PostgreSQL:** Robuste, Open-Source relationale Datenbank, die für ihre Zuverlässigkeit und Datenintegrität geschätzt wird.
  - **JWT (JSON Web Tokens):** Standard für token-basierte, zustandslose Authentifizierung.
  - **BCrypt:** Bewährter Algorithmus für sicheres Passwort-Hashing.
  - **Lombok:** Zur Reduzierung von Boilerplate-Code und Verbesserung der Lesbarkeit.

### Tools & Testing

  - **JUnit 5:** Modernes Testing Framework für Unit- und Integrationstests.
  - **Mockito:** Beliebtes Mocking Framework für isolierte Testfälle.
  - **Maven:** Standardisiertes Build-Management-Tool für Java-Projekte.
  - **Docker:** Containerisierung für konsistente Entwicklung, Test- und Produktionsumgebungen.

-----

## 🔒 Sicherheit & Compliance – Fundament des Vertrauens

Die Sicherheit sensibler Finanzdaten ist von größter Bedeutung. Dieses Projekt implementiert eine Reihe von **robusten Sicherheitsmaßnahmen**, die den Anforderungen der Bankenbranche an Datenschutz und Transaktionssicherheit Rechnung tragen.

### Implementierte Sicherheitsmaßnahmen:

1.  **JWT Tokens:**
      * **Stateless Authentication:** Fördert Skalierbarkeit und reduziert Serverlast.
      * **Konfigurierbare Ablaufzeiten (24h Standard):** Für eine flexible Sicherheitspolitik.
      * **HMAC-SHA256 Signing:** Gewährleistet die Integrität und Authentizität der Tokens.
2.  **Passwort-Sicherheit:**
      * **BCrypt Hashing (Salted):** Starker Schutz vor Brute-Force-Angriffen und Rainbow-Table-Angriffen.
      * **Mindestlängen-Validierung:** Erzwingt robuste Passwörter.
3.  **API Security:**
      * **Umfassender Schutz aller Account-APIs:** Nur authentifizierte und autorisierte Zugriffe sind möglich.
      * **Token-Validierung bei jeder Anfrage:** Kontinuierliche Überprüfung der Berechtigung.
      * **Automatischer Logout bei 401-Fehlern:** Sofortige Reaktion auf ungültige oder abgelaufene Tokens.
4.  **CORS Configuration:**
      * **Gezielte Konfiguration für `localhost:4200`:** Verhindert unautorisierte Cross-Origin-Zugriffe im Entwicklungsbetrieb. In Produktion flexibel anpassbar.
      * **Kontrollierte Zugriffs-Header:** Ermöglicht sichere Interaktionen zwischen Frontend und Backend.
5.  **Input Validation:**
      * **Frontend-Formularvalidierung:** Schnelles Feedback für den Benutzer.
      * **Backend DTO-Validierung:** Robuste serverseitige Validierung kritischer Daten.
      * **SQL Injection Prevention (JPA):** Schutz vor einer der häufigsten Web-Sicherheitslücken durch den Einsatz von ORM-Technologien.

-----

## 🧪 Qualitätssicherung & Teststrategie

Ein hoher Qualitätsanspruch, der sich in der **Codequalität und dem Testing** widerspiegelt, ist für Finanzanwendungen unerlässlich. Dieses Projekt demonstriert eine konsequente Teststrategie, um die **Funktionalität, Robustheit und Fehlerfreiheit** der Software zu gewährleisten.

### Backend Tests ausführen

```bash
# Auth Service Tests
cd auth-service
mvn test

# Account Service Tests
cd account-service
mvn test
```

### Testabdeckung & Szenarien:

  * **Auth Service Tests:** Abdeckung kritischer Authentifizierungsflüsse.
      * ✅ `loginBenutzerNichtGefunden()`: Testet das Szenario, wenn ein Benutzer nicht existiert.
      * ✅ `loginFalschesPasswort()`: Überprüft die korrekte Handhabung falscher Passwörter.
      * ✅ `loginErfolgreich()`: Validiert den erfolgreichen Anmeldevorgang.
      * ✅ `registerErfolgreich()`: Stellt sicher, dass neue Benutzer korrekt registriert werden können.
      * ✅ `registerExistiertBereits()`: Prüft die Ablehnung doppelter Registrierungen.
  * **Account Service Tests:** Fokus auf finanzrelevante Geschäftslogik.
      * ✅ `testGetAllAccounts()`: Verifiziert die korrekte Abfrage aller Konten.
      * ✅ `testCreateAccount()`: Testet die Erstellung neuer Konten.
      * ✅ `testTransferThrowsIfAccountNotFound()`: Stellt sicher, dass Transfers bei nicht existierenden Konten fehlschlagen.
      * ✅ `testTransferThrowsIfNotEnoughMoney()`: Prüft, ob Transfers bei unzureichendem Guthaben korrekt abgelehnt werden.

### Frontend Tests

```bash
cd frontend
npm test
```

Die Frontend-Tests stellen die korrekte Funktionalität der Benutzeroberfläche und die Integration mit den Backend-APIs sicher.

-----

## 🚀 Installation & Setup

Um das Bank Portal lokal in Betrieb zu nehmen, folgen Sie diesen Schritten:

### Voraussetzungen

  - **Node.js** (v18+) & **Angular CLI** (`npm install -g @angular/cli`) für das Frontend.
  - **Java 17+** & **Maven 3.6+** für das Backend.
  - **PostgreSQL 13+** (lokal oder via Docker) als Datenbanksystem.

### 1\. Repository Klonen

```bash
git clone <repository-url>
cd bank-portal
```

### 2\. Datenbank Setup

#### Option A: Docker (Empfohlen für schnelle Einrichtung)

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

### 3\. Backend Services Starten

#### Auth Service

```bash
cd auth-service
mvn clean install
mvn spring-boot:run
```

Der Auth Service ist dann unter `http://localhost:8081` erreichbar.

#### Account Service

```bash
cd account-service
mvn clean install
mvn spring-boot:run
```

Der Account Service ist dann unter `http://localhost:8082` erreichbar.

### 4\. Frontend Starten

```bash
cd frontend
npm install
ng serve
```

Das Frontend ist dann unter `http://localhost:4200` erreichbar.

-----

## ⚙️ Konfiguration

### Environment Variables

Stellen Sie sicher, dass die folgenden Umgebungsvariablen gesetzt sind, insbesondere das **JWT Secret**, welches in beiden Services identisch sein muss, um die korrekte Funktion der Authentifizierung zu gewährleisten.

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
spring.datasource.url=${AUTH_DB_URL:jdbc:postgresql://localhost:5432/authdb}
spring.datasource.username=admin
spring.datasource.password=admin
jwt.secret=${JWT_SECRET:mysecretkeymysecretkeymysecretkey123456}
jwt.expiration-ms=86400000
```

#### Account Service (`application.properties`)

```properties
server.port=8082
spring.datasource.url=${ACCOUNT_DB_URL:jdbc:postgresql://localhost:5433/accountdb}
spring.datasource.username=admin
spring.datasource.password=admin
jwt.secret=${JWT_SECRET:mysecretkeymysecretkeymysecretkey123456}
```

-----

## 📡 API Dokumentation

Die RESTful APIs der Mikroservices sind klar strukturiert und ermöglichen eine einfache Integration.

### Auth Service APIs

#### POST `/api/auth/register`

Registriert einen neuen Benutzer im System.

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

Authentifiziert einen Benutzer und gibt einen JWT Token zurück.

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

> **Hinweis:** Alle Account Service APIs erfordern den `Authorization: Bearer <token>` Header für den Zugriff.

#### GET `/api/accounts`

Ruft alle Konten ab, die dem authentifizierten Benutzer zugeordnet sind.

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

Erstellt ein neues Bankkonto für den authentifizierten Benutzer.

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

Führt einen Geldtransfer zwischen zwei Konten durch.

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

-----

## 🎨 Frontend Features – Benutzerfreundlichkeit & Effizienz

Das Angular Frontend ist auf eine **intuitive Benutzerführung und Effizienz** ausgelegt, um ein optimales Banking-Erlebnis zu gewährleisten.

### Schlüsselkomponenten & Services

1.  **LoginComponent / RegisterComponent:** Sichere Einstiegspunkte für Benutzer.
2.  **DashboardComponent:** Zentrale Übersicht über die wichtigsten Finanzdaten.
3.  **AccountListComponent:** Detaillierte Ansicht und Verwaltung der Konten.
4.  **NavigationComponent:** Benutzerfreundliche Navigation und sichere Abmeldung.
5.  **AuthService:** Zentrales Management für Authentifizierung und Token-Handhabung.
6.  **AccountService:** Kapselung der Geschäftslogik für Kontoverwaltung und Transfers.
7.  **AuthGuard:** Schutz kritischer Routen vor unautorisiertem Zugriff.
8.  **AuthInterceptor:** Automatische Integration von JWT Tokens in API-Anfragen.

### Features Highlights

  - ✅ **Responsives Design:** Optimale Darstellung auf allen Geräten (Desktop, Tablet, Mobile).
  - ✅ **Echtzeit-Validierung:** Sofortiges Feedback bei Formulareingaben zur Verbesserung der Datenqualität.
  - ✅ **Loading States & Error Handling:** Robuste Benutzerführung auch bei asynchronen Operationen und Fehlern.
  - ✅ **Währungsformatierung (EUR):** Fachgerechte Darstellung von Finanzbeträgen.
  - ✅ **Automatischer Logout bei Token-Expiry:** Erhöhte Sicherheit durch automatische Sitzungsbeendigung.
  - ✅ **Deutsche Lokalisierung:** Anpassung an den deutschsprachigen Markt.

-----

## 📝 Code-Struktur & Wartbarkeit

Eine **klare und modulare Code-Struktur** ist entscheidend für die Wartbarkeit und Erweiterbarkeit in der Finanzbranche. Die Projekte sind nach Best Practices organisiert, um die Zusammenarbeit im Team und die Einarbeitung neuer Entwickler zu erleichtern.

### Frontend (`/frontend`)

```
src/
├── app/
│   ├── components/            # UI Komponenten (z.B. Login, Register, Dashboard, Account List, Navigation)
│   ├── services/              # Business Logic (z.B. AuthService, AccountService)
│   ├── models/                # TypeScript Interfaces für Datenstrukturen
│   ├── guards/                # Route Guards für Zugriffskontrolle
│   ├── interceptors/          # HTTP Interceptors für Request-Transformation
│   └── app.routes.ts          # Routing Konfiguration
├── styles.scss                # Globale Styles
└── index.html                 # Haupt-HTML-Datei
```

### Backend Auth Service (`/auth-service`)

```
src/main/java/com/bankportal/authservice/
├── controller/                # REST Controllers für API-Endpunkte
├── service/                   # Business Logic Implementierungen
├── repository/                # Datenzugriffsschicht (JPA Repositories)
├── model/                     # JPA Entities (Datenbankmodelle)
├── dto/                       # Data Transfer Objects für API-Kommunikation
├── security/                  # Sicherheitskonfiguration (Spring Security, JWT)
└── config/                    # Allgemeine Anwendungskonfiguration
```

### Backend Account Service (`/account-service`)

```
src/main/java/com/example/bank/
├── AccountController.java     # REST Controller für Kontenoperationen
├── AccountService.java        # Geschäftslogik für Konten und Transfers
├── AccountRepository.java     # Datenzugriff für Konten
├── Account.java               # JPA Entity für Kontendaten
├── AccountDto.java            # DTO für Kontendaten
├── TransferRequest.java       # DTO für Transferanfragen
├── SecurityConfig.java        # Sicherheitskonfiguration & JWT Validierung
└── GlobalExceptionHandler.java# Zentrales Fehlerhandling
```

-----

## 🚀 Deployment & Betrieb

Das Projekt ist für eine einfache Containerisierung mit **Docker** vorbereitet, was eine konsistente Bereitstellung in verschiedenen Umgebungen (Entwicklung, Test, Produktion) ermöglicht – ein wichtiger Aspekt für **DevOps-Pipelines** in Banken.

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

Beispiel-Dockerfile für die Backend-Services zur einfachen Containerisierung:

```dockerfile
# Beispiel Dockerfile für Backend
FROM openjdk:17-jre-slim
COPY target/auth-service-*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

-----

## 🐛 Troubleshooting

Eine detaillierte Anleitung zur Fehlerbehebung ist für den reibungslosen Betrieb in einer Produktivumgebung essenziell.

### Häufige Probleme & Lösungen

#### 1\. "Connection refused" Fehler

**Problem:** Frontend kann Backend-Services nicht erreichen.
**Lösung:** Prüfen Sie, ob die Backend-Services (Auth, Account) auf den korrekten Ports laufen (`netstat -tlnp`) und starten Sie sie gegebenenfalls neu.

#### 2\. JWT Token Fehler

**Problem:** "Invalid or expired token".
**Lösung:** Melden Sie sich erneut an, überprüfen Sie das `JWT_SECRET` in beiden Services und die Token-Ablaufzeit.

#### 3\. Datenbank Connection Fehler

**Problem:** "Connection to database failed".
**Lösung:** Überprüfen Sie den Status der PostgreSQL-Instanzen (lokal oder Docker) und testen Sie die Datenbankverbindung.

#### 4\. CORS Fehler

**Problem:** "Access to fetch blocked by CORS policy".
**Lösung:** Überprüfen Sie die CORS-Konfiguration in `SecurityConfig.java` der Backend-Services und stellen Sie sicher, dass die Frontend-URL korrekt in `allowedOrigins` gesetzt ist.

#### 5\. Port Konflikte

**Problem:** "Port already in use".
**Lösung:** Finden Sie den Prozess, der den Port belegt, und beenden Sie ihn (`lsof -ti:<PORT> | xargs kill -9`).

### Logs

Für eine effektive Fehleranalyse in einer Bankenumgebung sind detaillierte Logs unerlässlich.

#### Backend Logs anzeigen

```bash
# Mit Maven
mvn spring-boot:run | grep -E "(ERROR|WARN|INFO)"

# Application Logs
tail -f logs/application.log
```

#### Frontend Logs

Verwenden Sie die Browser Developer Tools (Konsole) für Frontend-spezifische Fehler.

### Debug Mode

```bash
# Backend mit Debug
mvn spring-boot:run -Dspring.profiles.active=debug

# Frontend mit Debug
ng serve --verbose
```

-----

## Screenshot

[Frontend UI-Screenshots (PDF)](docs/frontend.pdf) – Ein visueller Einblick in die Anwendung.

-----

## 📄 Lizenz

Dieses Projekt ist unter der **MIT Lizenz** veröffentlicht, was die Nutzung und Modifikation unter den gegebenen Bedingungen erlaubt.


-----

**Version:** 1.0.0
**Letztes Update:** Juli 2025
