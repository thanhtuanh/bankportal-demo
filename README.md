# 🏦 Bank Portal – Eine zukunftssichere Finanzanwendung

Eine **moderne, mikroservice-basierte Banking-Plattform** mit einem responsiven Angular Frontend und einem robusten Spring Boot Backend, speziell entwickelt, um die hohen Anforderungen der Finanzbranche an **Sicherheit, Skalierbarkeit und Zuverlässigkeit** zu erfüllen.

-----

## 🎯 Überblick & Relevanz für die Bankenbranche

Das **Bank Portal** ist eine vollständige Banking-Anwendung, die **Kernfunktionen eines modernen Finanzinstituts** abbildet und dabei höchsten Wert auf **Sicherheit, Datenintegrität und Benutzerfreundlichkeit** legt. Dieses Projekt demonstriert die Fähigkeit, komplexe **Softwarelösungen für regulierte Umfelder** zu entwickeln, die den Anforderungen an eine ausfallsichere und performante Bankensoftware gerecht werden.

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
│   Angular SPA   │────►│   Auth Service  │────►│ Account Service │
│   (Port 4200)   │     │   (Port 8081)   │     │   (Port 8082)   │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │                       │
                               ▼                       ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │  PostgreSQL 15  │     │  PostgreSQL 15  │
                        │   (Auth DB)     │     │ (Account DB)    │
                        │   Port 5432     │     │ Port 5433       │
                        └─────────────────┘     └─────────────────┘
```

### Services & Verantwortlichkeiten:

1. **Frontend (Angular):**
   * **User Experience (UX):** Single Page Application mit responsivem Design für eine nahtlose Benutzerführung.
   * **Sichere Client-Seite:** JWT Token Management und Route Guards zum Schutz sensibler Bereiche.
   * **Effiziente Kommunikation:** HTTP Client für die performante Interaktion mit den Backend-Services.

2. **Auth Service (Spring Boot):**
   * **Identitätsmanagement:** Sichere Benutzerregistrierung und Login/Logout-Funktionalität.
   * **Token-Ausstellung:** Robuste JWT Token Generation für authentifizierte Sitzungen.
   * **Passwort-Sicherheit:** Industriestandard BCrypt Hashing für den Schutz von Benutzerpasswörtern.

3. **Account Service (Spring Boot):**
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
- **PostgreSQL 15:** Robuste, Open-Source relationale Datenbank, die für ihre Zuverlässigkeit und Datenintegrität geschätzt wird.
- **JWT (JSON Web Tokens):** Standard für token-basierte, zustandslose Authentifizierung.
- **BCrypt:** Bewährter Algorithmus für sicheres Passwort-Hashing.
- **Lombok:** Zur Reduzierung von Boilerplate-Code und Verbesserung der Lesbarkeit.

### DevOps & Container
- **Docker:** Containerisierung für konsistente Entwicklung, Test- und Produktionsumgebungen.
- **Kubernetes:** Orchestrierung für Skalierung und Verwaltung containerisierter Anwendungen.
- **Kustomize:** Deklaratives Konfigurationsmanagement für verschiedene Umgebungen.
- **Nginx:** Hochperformanter Webserver und Reverse Proxy für das Frontend.

### Tools & Testing
- **JUnit 5:** Modernes Testing Framework für Unit- und Integrationstests.
- **Mockito:** Beliebtes Mocking Framework für isolierte Testfälle.
- **Maven:** Standardisiertes Build-Management-Tool für Java-Projekte.

-----

## 🚀 Quick Start

### 1. Lokale Entwicklung mit Docker Compose
```bash
# Repository klonen
git clone <repository-url>
cd bankportal-demo

# Lokales Setup mit PostgreSQL 15
chmod +x scripts/setup-local.sh
./scripts/setup-local.sh compose

# Oder mit Makefile
make dev

# Services sind verfügbar unter:
# Frontend: http://localhost:4200
# Auth API: http://localhost:8081
# Account API: http://localhost:8082
```

### 2. Kubernetes Deployment
```bash
# Kubernetes Deployment mit PostgreSQL 15
chmod +x scripts/deploy-k8s.sh
./scripts/deploy-k8s.sh deploy development

# Oder mit Makefile
make k8s-dev

# Port-Forward für lokalen Zugriff
kubectl port-forward svc/frontend-service 8080:80 -n bankportal
# Oder
make port-forward
```

-----

## 📁 Ordnerstruktur

```
bankportal-demo/
├── auth-service/           # Authentifizierung Service
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
├── account-service/        # Kontenverwaltung Service
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
├── frontend/               # Angular Frontend
│   ├── src/
│   ├── package.json
│   ├── Dockerfile
│   └── nginx.conf
├── k8s/                    # Kubernetes Manifeste
│   ├── base/               # Base Konfiguration
│   └── overlays/           # Environment-spezifisch
├── scripts/                # Deployment Scripts
│   ├── setup-local.sh      # Lokales Setup
│   ├── deploy-k8s.sh       # Kubernetes Deployment
│   └── build-images.sh     # Docker Image Build
├── docker-compose.yml      # Lokale Entwicklung
├── Makefile               # Vereinfachte Befehle
└── README.md
```

-----

## 🔧 Installation & Setup

### Voraussetzungen

**Für lokale Entwicklung:**
- Docker & Docker Compose
- Node.js 18+ (für Frontend Development)
- Java 17+ (für Backend Development)
- Maven 3.6+ (für Backend Build)

**Für Kubernetes:**
- Kubernetes Cluster (local/cloud)
- kubectl CLI
- Docker für Image Builds

### Setup-Optionen

#### Option 1: Docker Compose (Empfohlen für Development)
```bash
# Vollständiges lokales Setup
./scripts/setup-local.sh compose
# oder
make dev

# Nur Datenbanken, Services manuell
./scripts/setup-local.sh standalone
# oder
make dev-standalone

# Cleanup
./scripts/setup-local.sh cleanup
# oder
make clean-docker
```

#### Option 2: Kubernetes
```bash
# Development Environment
./scripts/deploy-k8s.sh deploy development
# oder
make k8s-dev

# Production Environment
./scripts/deploy-k8s.sh deploy production
# oder
make k8s-prod

# Status prüfen
./scripts/deploy-k8s.sh status
# oder
make k8s-status

# Cleanup
./scripts/deploy-k8s.sh cleanup
# oder
make k8s-clean
```

-----

## 🗄️ Datenbank-Konfiguration (PostgreSQL 15)

### Lokale Entwicklung
- **Auth DB:** `postgresql://admin:admin@localhost:5432/authdb`
- **Account DB:** `postgresql://admin:admin@localhost:5433/accountdb`

### Kubernetes
- **Auth DB:** `postgresql://admin:admin@postgres-auth-service:5432/authdb`
- **Account DB:** `postgresql://admin:admin@postgres-account-service:5432/accountdb`

### Schema
```sql
-- Auth Database (authdb)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Account Database (accountdb)
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    owner VARCHAR(100) NOT NULL,
    balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Datenbank-Management mit Makefile
```bash
# Verbindung zu Datenbanken
make db-auth          # Auth Database
make db-account       # Account Database

# Backup erstellen
make db-backup

# Restore aus Backup
make db-restore BACKUP_FILE=backups/authdb_20241204_120000.sql
```

-----

## 🔒 Sicherheit & Compliance – Fundament des Vertrauens

Die Sicherheit sensibler Finanzdaten ist von größter Bedeutung. Dieses Projekt implementiert eine Reihe von **robusten Sicherheitsmaßnahmen**, die den Anforderungen der Bankenbranche an Datenschutz und Transaktionssicherheit Rechnung tragen.

### Implementierte Sicherheitsmaßnahmen:

1. **JWT Tokens:**
   * **Stateless Authentication:** Fördert Skalierbarkeit und reduziert Serverlast.
   * **Konfigurierbare Ablaufzeiten (24h Standard):** Für eine flexible Sicherheitspolitik.
   * **HMAC-SHA256 Signing:** Gewährleistet die Integrität und Authentizität der Tokens.

2. **Passwort-Sicherheit:**
   * **BCrypt Hashing (Salted):** Starker Schutz vor Brute-Force-Angriffen und Rainbow-Table-Angriffen.
   * **Mindestlängen-Validierung:** Erzwingt robuste Passwörter.

3. **API Security:**
   * **Umfassender Schutz aller Account-APIs:** Nur authentifizierte und autorisierte Zugriffe sind möglich.
   * **Token-Validierung bei jeder Anfrage:** Kontinuierliche Überprüfung der Berechtigung.
   * **Automatischer Logout bei 401-Fehlern:** Sofortige Reaktion auf ungültige oder abgelaufene Tokens.

4. **Kubernetes Security:**
   * **Non-root Container:** Alle Container laufen als non-root User.
   * **Resource Limits:** CPU/Memory Limits gesetzt.
   * **Secrets Management:** Sensitive Daten in Kubernetes Secrets.
   * **Network Policies:** Pod-zu-Pod Kommunikation beschränkt.

5. **Input Validation:**
   * **Frontend-Formularvalidierung:** Schnelles Feedback für den Benutzer.
   * **Backend DTO-Validierung:** Robuste serverseitige Validierung kritischer Daten.
   * **SQL Injection Prevention (JPA):** Schutz vor einer der häufigsten Web-Sicherheitslücken durch den Einsatz von ORM-Technologien.

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

### API Tests mit Makefile
```bash
# Einfache API Tests
make test-api

# Umfassende Tests
make test
```

-----

## 🎨 Frontend Features – Benutzerfreundlichkeit & Effizienz

Das Angular Frontend ist auf eine **intuitive Benutzerführung und Effizienz** ausgelegt, um ein optimales Banking-Erlebnis zu gewährleisten.

### Schlüsselkomponenten & Services

1. **LoginComponent / RegisterComponent:** Sichere Einstiegspunkte für Benutzer.
2. **DashboardComponent:** Zentrale Übersicht über die wichtigsten Finanzdaten.
3. **AccountListComponent:** Detaillierte Ansicht und Verwaltung der Konten.
4. **NavigationComponent:** Benutzerfreundliche Navigation und sichere Abmeldung.
5. **AuthService:** Zentrales Management für Authentifizierung und Token-Handhabung.
6. **AccountService:** Kapselung der Geschäftslogik für Kontoverwaltung und Transfers.
7. **AuthGuard:** Schutz kritischer Routen vor unautorisiertem Zugriff.
8. **AuthInterceptor:** Automatische Integration von JWT Tokens in API-Anfragen.

### Features Highlights

- ✅ **Responsives Design:** Optimale Darstellung auf allen Geräten (Desktop, Tablet, Mobile).
- ✅ **Echtzeit-Validierung:** Sofortiges Feedback bei Formulareingaben zur Verbesserung der Datenqualität.
- ✅ **Loading States & Error Handling:** Robuste Benutzerführung auch bei asynchronen Operationen und Fehlern.
- ✅ **Währungsformatierung (EUR):** Fachgerechte Darstellung von Finanzbeträgen.
- ✅ **Automatischer Logout bei Token-Expiry:** Erhöhte Sicherheit durch automatische Sitzungsbeendigung.
- ✅ **Deutsche Lokalisierung:** Anpassung an den deutschsprachigen Markt.

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

# Alle Tests mit Makefile
make test
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

# Mit Makefile
make test
```

-----

## 🎛️ Environment Management

### Development
```bash
# Mit Docker Compose
docker-compose up -d
# oder
make dev

# Mit Kubernetes
kubectl apply -k k8s/overlays/development
# oder
make k8s-dev
```

### Staging
```bash
kubectl apply -k k8s/overlays/staging
```

### Production
```bash
kubectl apply -k k8s/overlays/production
# oder
make k8s-prod
```

-----

## 📊 Monitoring & Observability

### Health Checks
```bash
# Lokale Services
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health

# Mit Makefile
make test-api

# Kubernetes (mit Port-Forward)
kubectl port-forward svc/auth-service 8081:8081 -n bankportal
curl http://localhost:8081/actuator/health

# Oder mit Makefile
make k8s-health
```

### Logs
```bash
# Docker Compose
docker-compose logs -f
# oder
make logs

# Spezifische Services
make logs-auth        # Auth Service
make logs-account     # Account Service
make logs-db          # PostgreSQL

# Kubernetes
kubectl logs -f deployment/auth-service -n bankportal
# oder
make k8s-logs
```

### Kubernetes Resources
```bash
# Pod Status
kubectl get pods -n bankportal

# Service Status  
kubectl get svc -n bankportal

# Mit Makefile
make k8s-status

# Resource Usage
kubectl top pods -n bankportal
kubectl top nodes
```

-----

## 🚀 Deployment Strategien

### Docker Image Build
```bash
# Development Images
./scripts/build-images.sh development latest
# oder
make build

# Production Images
./scripts/build-images.sh production latest --push
# oder
make build-prod
```

### Rolling Update
```bash
# Neue Version deployen
kubectl set image deployment/auth-service auth-service=bankportal/auth-service:v2.0.0 -n bankportal

# Rollback
kubectl rollout undo deployment/auth-service -n bankportal
```

### Blue-Green Deployment
```bash
# Blue Environment (aktuell)
kubectl apply -k k8s/overlays/production

# Green Environment (neue Version)
kubectl apply -k k8s/overlays/production-green

# Traffic Switch
kubectl patch service auth-service -p '{"spec":{"selector":{"version":"green"}}}' -n bankportal
```

-----

## 🔄 Skalierung

### Horizontal Pod Autoscaler
```bash
# HPA aktivieren
kubectl autoscale deployment auth-service --cpu-percent=70 --min=2 --max=10 -n bankportal

# Status prüfen
kubectl get hpa -n bankportal
# oder
make k8s-status

# Manuelle Skalierung
kubectl scale deployment auth-service --replicas=5 -n bankportal
```

-----

## 🛠️ Troubleshooting

### Häufige Probleme & Lösungen

#### 1. "Connection refused" Fehler
**Problem:** Frontend kann Backend-Services nicht erreichen.
**Lösung:** 
```bash
# Status prüfen
make status                    # Docker Compose
make k8s-status               # Kubernetes

# Services neu starten
make dev                      # Lokale Entwicklung
make k8s-dev                  # Kubernetes
```

#### 2. JWT Token Fehler
**Problem:** "Invalid or expired token".
**Lösung:** Melden Sie sich erneut an, überprüfen Sie das `JWT_SECRET` in beiden Services und die Token-Ablaufzeit.

#### 3. Datenbank Connection Fehler
**Problem:** "Connection to database failed".
**Lösung:** 
```bash
# Datenbank Status prüfen
make test-db

# Datenbank Verbindung testen
make db-auth          # Auth Database
make db-account       # Account Database
```

#### 4. PostgreSQL 15 spezifische Probleme
```bash
# PostgreSQL Logs prüfen
make logs-db

# Direkter Datenbankzugriff
make db-auth
make db-account

# Backup/Restore
make db-backup
make db-restore BACKUP_FILE=backups/authdb_20241204_120000.sql
```

### Debug Commands
```bash
# Interactive Shell in Pod (Kubernetes)
kubectl exec -it deployment/auth-service -n bankportal -- /bin/bash

# Database Shell (Kubernetes)
kubectl exec -it deployment/postgres-auth -n bankportal -- psql -U admin -d authdb

# Network Debugging
kubectl run debug --image=nicolaka/netshoot --rm -it --restart=Never -n bankportal
```

### Makefile Shortcuts
```bash
# Übersicht aller verfügbaren Befehle
make help

# Schnelle Entwicklung
make quick-start        # Alias für make dev

# Vollständiges Deployment
make full-deploy        # Build + Deploy + Port-Forward

# System Informationen
make info               # Zeigt installierte Tools
make urls               # Zeigt alle Service URLs

# Komplettes Cleanup
make clean              # Docker + Kubernetes
make clean-docker       # Nur Docker
make clean-k8s          # Nur Kubernetes
```

-----

## 📈 CI/CD Integration

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy to Kubernetes
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Build Images
      run: ./scripts/build-images.sh production ${{ github.sha }}
    - name: Deploy to Kubernetes  
      run: ./scripts/deploy-k8s.sh deploy production
```

### GitLab CI
```yaml
# .gitlab-ci.yml
stages:
  - build
  - deploy

build:
  stage: build
  script:
    - ./scripts/build-images.sh production $CI_COMMIT_SHA

deploy:
  stage: deploy
  script:
    - ./scripts/deploy-k8s.sh deploy production
```

-----

## 📚 Weiterführende Dokumentation

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Angular Documentation](https://angular.io/docs)
- [PostgreSQL 15 Documentation](https://www.postgresql.org/docs/15/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

-----

## 🎯 Service URLs & Quick Access

### Lokale Entwicklung (Docker Compose)
- **Frontend:** http://localhost:4200
- **Auth Service:** http://localhost:8081
- **Account Service:** http://localhost:8082
- **Auth DB:** postgresql://admin:admin@localhost:5432/authdb
- **Account DB:** postgresql://admin:admin@localhost:5433/accountdb

### Kubernetes (mit Port-Forward)
- **Frontend:** http://localhost:8080
- **Auth Service:** http://localhost:8081
- **Account Service:** http://localhost:8082

### API Endpoints
- `POST /api/auth/register` - Benutzerregistrierung
- `POST /api/auth/login` - Benutzeranmeldung
- `GET /api/accounts` - Alle Konten abrufen
- `POST /api/accounts` - Neues Konto erstellen
- `POST /api/accounts/transfer` - Geldtransfer

-----

## 🤝 Contributing

1. Fork das Repository
2. Feature Branch erstellen (`git checkout -b feature/amazing-feature`)
3. Changes committen (`git commit -m 'Add amazing feature'`)
4. Branch pushen (`git push origin feature/amazing-feature`)
5. Pull Request öffnen

-----

## 📄 Lizenz

Dieses Projekt ist unter der **MIT Lizenz** veröffentlicht – siehe [LICENSE](LICENSE) Datei für Details.

-----

## 📞 Support

Bei Fragen oder Problemen:
- Issue im Repository erstellen
- [Kubernetes Community](https://kubernetes.io/community/)
- [Spring Boot Community](https://spring.io/community)

-----

**Version:** 2.0.0 mit PostgreSQL 15 & Kubernetes  
**Letztes Update:** Juli 2025