# 🏦 Bank Portal - Entwickler-Dokumentation
# Vollständige DevOps & Development Anleitung

> **Enterprise-Grade Banking Platform mit modernen DevOps-Praktiken**  
> Java 17 + Spring Boot 3.4 + Angular 18 + PostgreSQL 15 + Docker + Kubernetes

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.java.net/projects/jdk/17/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Angular](https://img.shields.io/badge/Angular-18-red.svg)](https://angular.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![SpringDoc](https://img.shields.io/badge/SpringDoc-2.7.0-green.svg)](https://springdoc.org/)

---

## 📋 **Inhaltsverzeichnis**

1. [🎯 Projektübersicht](#-projektübersicht)
2. [🏗️ Architektur & Technologie-Stack](#️-architektur--technologie-stack)
3. [⚡ Schnellstart](#-schnellstart)
4. [🔧 Development Setup](#-development-setup)
5. [🐳 Docker Deployment](#-docker-deployment)
6. [💾 Backup & Recovery](#-backup--recovery)
7. [☸️ Kubernetes Deployment](#️-kubernetes-deployment)
8. [🧪 Testing](#-testing)
9. [📊 Monitoring & Observability](#-monitoring--observability)
10. [🔒 Security](#-security)
11. [🚀 Production Deployment](#-production-deployment)
12. [🛠️ Troubleshooting](#️-troubleshooting)

---

## 🎯 **Projektübersicht**

### **Was ist Bank Portal?**

Das Bank Portal ist eine **vollständige, moderne Banking-Plattform**, die als **DevOps-Lernprojekt** und **Production-Ready Referenz-Implementierung** entwickelt wurde. Es demonstriert moderne Software-Entwicklung mit Enterprise-Grade DevOps-Praktiken.

### **🎯 Kernfunktionalitäten**

#### **🔐 Authentication Service (Port 8081)**
- **JWT-basierte Authentifizierung** mit BCrypt-Hashing
- **Benutzer-Registrierung** und sichere Anmeldung
- **Token-Validierung** für andere Services
- **Swagger UI**: http://localhost:8081/swagger-ui/index.html

#### **💼 Account Service (Port 8082)**
- **Konto-Management** (CRUD Operationen)
- **Geld-Transfers** zwischen Konten mit ACID-Compliance
- **Transaktionshistorie** und Saldo-Verwaltung
- **Swagger UI**: http://localhost:8082/swagger-ui/index.html

#### **🌐 Frontend (Port 4200)**
- **Angular 18 SPA** mit TypeScript
- **Responsive Design** für alle Geräte
- **JWT Token Management** und Auto-Refresh
- **Real-time Dashboard** mit Account-Übersicht

### **🏆 DevOps-Features**

- ✅ **Docker Containerization** mit Multi-Stage Builds
- ✅ **Production-Ready Backup System** mit WAL-Archiving
- ✅ **Kubernetes Deployment** mit Helm Charts
- ✅ **CI/CD Pipeline** mit GitHub Actions
- ✅ **Monitoring & Observability** (Prometheus, Grafana)
- ✅ **Security Scanning** und Best Practices
- ✅ **Automated Testing** (Unit, Integration, E2E)

---

## 🏗️ **Architektur & Technologie-Stack**

### **🎨 System-Architektur**

```
┌─────────────────────────────────────────────────────────┐
│                    🌐 FRONTEND LAYER                    │
│  Angular 18 SPA  │  nginx Proxy  │  SSL/TLS Security   │
│  • TypeScript    │  • Load Bal.  │  • HTTPS/WSS        │
│  • Responsive UI │  • Caching    │  • CORS Headers     │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                🔧 API GATEWAY & SECURITY                │
│  JWT Auth       │  Rate Limiting  │  API Routing       │
│  • Token Valid. │  • DDoS Protect │  • Load Balance    │
│  • User Session │  • Monitoring   │  • Health Checks   │
└─────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ 🔐 Auth Service │  │💼 Account Service│  │🔮 Future Services│
│                 │  │                 │  │                 │
│ • User Mgmt     │  │ • Account CRUD  │  │ • Notifications │
│ • JWT Tokens    │  │ • Money Transfer│  │ • Analytics     │
│ • Registration  │  │ • Balance Check │  │ • Reporting     │
│ • Spring Boot   │  │ • Spring Boot   │  │ • Extensible    │
│ • Port 8081     │  │ • Port 8082     │  │ • Port 808x     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
              │               │               │
              ▼               ▼               ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   PostgreSQL    │  │   PostgreSQL    │  │   Monitoring    │
│   Auth Database │  │ Account Database│  │   & Backup      │
│                 │  │                 │  │                 │
│ • Users/Roles   │  │ • Accounts      │  │ • Prometheus    │
│ • JWT Sessions  │  │ • Transactions  │  │ • Grafana       │
│ • Audit Logs    │  │ • WAL Archive   │  │ • Backup System │
│ • Port 5433     │  │ • Port 5434     │  │ • Health Checks │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### **💻 Technologie-Stack**

#### **Backend (Java Ecosystem)**
```yaml
Java: 17 (LTS)
Spring Boot: 3.4.4
Spring Security: JWT + BCrypt
Spring Data JPA: Database Abstraction
SpringDoc OpenAPI: 2.7.0 (Swagger UI)
PostgreSQL: 15-alpine
Maven: Build & Dependency Management
```

#### **Frontend (Modern Web)**
```yaml
Angular: 18
TypeScript: Latest
RxJS: Reactive Programming
SCSS: Styling
Cypress: E2E Testing
ESLint: Code Quality
```

#### **DevOps & Infrastructure**
```yaml
Docker: Containerization
Docker Compose: Multi-Service Orchestration
Kubernetes: Container Orchestration
nginx: Reverse Proxy & Load Balancing
Prometheus: Metrics Collection
Grafana: Monitoring Dashboards
GitHub Actions: CI/CD Pipeline
```

---

## ⚡ **Schnellstart**

### **🚀 Ein-Klick Development Setup**

```bash
# 1. Repository klonen
git clone https://github.com/thanhtuanh/bankportal-demo.git
cd bankportal-demo

# 2. Development Environment starten
docker-compose up -d

# 3. Services testen (nach ~2 Minuten)
curl http://localhost:8081/api/health  # Auth Service
curl http://localhost:8082/api/health  # Account Service
open http://localhost:4200             # Frontend
```

### **📊 Service URLs**

| Service | URL | Beschreibung |
|---------|-----|--------------|
| **Frontend** | http://localhost:4200 | Angular SPA |
| **Auth API** | http://localhost:8081/api | Authentication Service |
| **Account API** | http://localhost:8082/api | Account Management |
| **Auth Swagger** | http://localhost:8081/swagger-ui/index.html | API Dokumentation |
| **Account Swagger** | http://localhost:8082/swagger-ui/index.html | API Dokumentation |
| **Auth DB** | localhost:5433 | PostgreSQL (admin/admin) |
| **Account DB** | localhost:5434 | PostgreSQL (admin/admin) |

### **🧪 Schnell-Test**

```bash
# 1. Benutzer registrieren
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}'

# 2. JWT Token erhalten
TOKEN=$(curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}' \
  | jq -r '.token')

# 3. Konto erstellen
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"owner": "testuser", "balance": 1000.0}'

# 4. Konten anzeigen
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8082/api/accounts
```

---

## 🔧 **Development Setup**

### **📋 Voraussetzungen**

#### **Erforderlich:**
- **Java 17+** (OpenJDK empfohlen)
- **Node.js 18+** mit npm
- **Docker & Docker Compose**
- **Git**

#### **Optional (für lokale Entwicklung):**
- **Maven 3.8+**
- **PostgreSQL 15+**
- **IntelliJ IDEA / VS Code**

### **🛠️ Lokale Entwicklung ohne Docker**

#### **1. Datenbanken starten**
```bash
# PostgreSQL mit Docker starten
docker run -d --name postgres-auth \
  -e POSTGRES_DB=authdb \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin \
  -p 5433:5432 postgres:15-alpine

docker run -d --name postgres-account \
  -e POSTGRES_DB=accountdb \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin \
  -p 5434:5432 postgres:15-alpine
```

#### **2. Backend Services starten**
```bash
# Auth Service
cd auth-service
mvn clean install
mvn spring-boot:run

# Account Service (neues Terminal)
cd account-service
mvn clean install
mvn spring-boot:run
```

#### **3. Frontend starten**
```bash
cd frontend
npm install
npm start
```

### **🔧 IDE Setup**

#### **IntelliJ IDEA Konfiguration:**
```yaml
Project SDK: Java 17
Maven: Auto-import enabled
Spring Boot: Plugin aktiviert
Database: PostgreSQL Driver
Code Style: Google Java Style
```

#### **VS Code Extensions:**
```json
{
  "recommendations": [
    "vscjava.vscode-java-pack",
    "pivotal.vscode-spring-boot",
    "angular.ng-template",
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss"
  ]
}
```

---

## 🐳 **Docker Deployment**

### **📊 Deployment-Optionen**

| Datei | Zweck | Features |
|-------|-------|----------|
| `docker-compose.yml` | **Development** | Basis-Setup, schnell |
| `docker-compose-backup.yml` | **Production** | Backup, Monitoring, WAL |

### **🔧 Development Deployment**

```bash
# Standard Development Setup
docker-compose up -d

# Mit Build (bei Code-Änderungen)
docker-compose up -d --build

# Logs verfolgen
docker-compose logs -f

# Services stoppen
docker-compose down
```

### **🚀 Production Deployment mit Backup**

```bash
# Production-Ready Setup mit Backup-System
docker-compose -f docker-compose-backup.yml up -d

# Status überprüfen
docker-compose -f docker-compose-backup.yml ps

# Backup-Service Logs
docker-compose -f docker-compose-backup.yml logs backup-service
```

### **🔍 docker-compose-backup.yml Features**

#### **💾 Erweiterte Database-Konfiguration**
```yaml
postgres-auth:
  environment:
    # WAL (Write-Ahead Logging) für Point-in-Time Recovery
    POSTGRES_INITDB_ARGS: "--wal-level=replica --archive-mode=on --archive-command='cp %p /var/lib/postgresql/wal_archive/%f'"
  volumes:
    - auth_data:/var/lib/postgresql/data
    - auth_wal_archive:/var/lib/postgresql/wal_archive  # WAL Archive
    - ./scripts/postgres-init:/docker-entrypoint-initdb.d  # Init Scripts
    - ./backups/auth:/var/backups/auth  # Backup Directory
  restart: unless-stopped
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
```

#### **🔄 Dedicated Backup Service**
```yaml
backup-service:
  build:
    dockerfile: Dockerfile.backup
  environment:
    - BACKUP_SCHEDULE=0 2 * * *  # Täglich um 2 Uhr
    - RETENTION_DAYS=30          # 30 Tage Aufbewahrung
    - AUTH_DB_HOST=postgres-auth
    - ACCOUNT_DB_HOST=postgres-account
  volumes:
    - ./backups:/var/backups/bankportal
    - ./scripts:/opt/scripts
    - backup_logs:/var/log
```

### **📊 Container-Übersicht**

```bash
# Alle Container anzeigen
docker-compose -f docker-compose-backup.yml ps

# Erwartete Services:
# - postgres-auth      (Database mit WAL)
# - postgres-account   (Database mit WAL)
# - auth-service       (Spring Boot)
# - account-service    (Spring Boot)
# - frontend           (Angular + nginx)
# - backup-service     (Automated Backups)
```

---

## 💾 **Backup & Recovery**

### **🔄 Automatisches Backup-System**

Das Production-Setup (`docker-compose-backup.yml`) enthält ein **vollständiges Backup-System**:

#### **📅 Backup-Schedule**
- **Täglich um 2:00 Uhr** automatische Backups
- **30 Tage Retention** (konfigurierbar)
- **WAL-Archiving** für Point-in-Time Recovery
- **Komprimierte Backups** mit Timestamps

#### **🛠️ Manuelle Backup-Operationen**

```bash
# Sofortiges Backup erstellen
./scripts/db-backup.sh

# Backup mit spezifischem Namen
./scripts/db-backup.sh "manual-backup-$(date +%Y%m%d)"

# Backup-Status überprüfen
ls -la backups/
```

#### **🔄 Recovery-Operationen**

```bash
# Verfügbare Backups anzeigen
./scripts/db-recovery.sh --list

# Vollständige Wiederherstellung
./scripts/db-recovery.sh --restore latest

# Point-in-Time Recovery
./scripts/db-recovery.sh --restore "2024-07-05_02-00-00" --target-time "2024-07-05 14:30:00"

# Einzelne Datenbank wiederherstellen
./scripts/db-recovery.sh --restore latest --database auth
```

### **📊 Backup-Monitoring**

```bash
# Backup-Service Status
docker-compose -f docker-compose-backup.yml logs backup-service

# Backup-Größen überprüfen
du -sh backups/*

# WAL-Archive überprüfen
docker exec postgres-auth ls -la /var/lib/postgresql/wal_archive/
```

### **🔒 Backup-Sicherheit**

- **Verschlüsselte Backups** (AES-256)
- **Checksummen-Validierung** für Integrität
- **Offsite-Backup** Unterstützung (S3, Azure Blob)
- **Backup-Rotation** mit konfigurierbarer Retention

---

## ☸️ **Kubernetes Deployment**

### **🚀 Kubernetes Setup**

#### **1. Lokales Kubernetes (Minikube)**
```bash
# Minikube starten
minikube start --cpus=4 --memory=8192

# Kubernetes Dashboard
minikube dashboard

# Bank Portal deployen
kubectl apply -f k8s/dev/
```

#### **2. Production Kubernetes**
```bash
# Namespace erstellen
kubectl create namespace bankportal-prod

# Secrets erstellen
kubectl create secret generic db-credentials \
  --from-literal=auth-db-password=secure-password \
  --from-literal=account-db-password=secure-password \
  -n bankportal-prod

# Services deployen
kubectl apply -f k8s/dev/ -n bankportal-prod
```

### **📊 Kubernetes Services**

```bash
# Service Status
kubectl get pods,services,ingress

# Logs verfolgen
kubectl logs -f deployment/auth-service
kubectl logs -f deployment/account-service

# Port Forwarding für lokalen Zugriff
kubectl port-forward service/auth-service 8081:8081
kubectl port-forward service/account-service 8082:8082
kubectl port-forward service/frontend 4200:80
```

### **🔧 Kubernetes Konfiguration**

#### **Deployment Beispiel (auth-service):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: auth-service
  template:
    spec:
      containers:
      - name: auth-service
        image: bankportal/auth-service:latest
        ports:
        - containerPort: 8081
        env:
        - name: SPRING_DATASOURCE_URL
          value: "jdbc:postgresql://postgres-auth:5432/authdb"
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: auth-db-password
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8081
          initialDelaySeconds: 10
          periodSeconds: 5
```

---

## 🧪 **Testing**

### **🔬 Test-Kategorien**

#### **1. Unit Tests**
```bash
# Backend Unit Tests
cd auth-service && mvn test
cd account-service && mvn test

# Frontend Unit Tests
cd frontend && npm test
```

#### **2. Integration Tests**
```bash
# API Integration Tests
./scripts/test-auth-service.sh
./scripts/test-api.sh

# Database Integration Tests
docker-compose -f docker-compose-backup.yml exec postgres-auth \
  psql -U admin -d authdb -c "SELECT COUNT(*) FROM users;"
```

#### **3. End-to-End Tests**
```bash
# Cypress E2E Tests
cd frontend
npm run e2e:ci

# Manual E2E Test Flow
# 1. Benutzer registrieren: http://localhost:4200/register
# 2. Anmelden: http://localhost:4200/login
# 3. Konto erstellen: Dashboard -> "Neues Konto"
# 4. Geld überweisen: Dashboard -> "Überweisung"
```

### **📊 Test-Automatisierung**

#### **GitHub Actions CI/CD**
```yaml
# .github/workflows/ci-cd.yml
name: Bank Portal CI/CD
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v4
    - name: Setup Java 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Run Backend Tests
      run: |
        cd auth-service && mvn test
        cd ../account-service && mvn test
    
    - name: Run Frontend Tests
      run: |
        cd frontend
        npm ci
        npm test -- --watch=false --browsers=ChromeHeadless
```

### **🔍 Test-Coverage**

```bash
# Backend Test Coverage
cd auth-service && mvn jacoco:report
cd account-service && mvn jacoco:report

# Frontend Test Coverage
cd frontend && npm test -- --code-coverage

# Coverage Reports anzeigen
open auth-service/target/site/jacoco/index.html
open account-service/target/site/jacoco/index.html
open frontend/coverage/index.html
```

### **⚡ Performance Tests**

```bash
# Load Testing mit Apache Bench
ab -n 1000 -c 10 http://localhost:8081/api/health

# JMeter Performance Tests
jmeter -n -t tests/performance/bankportal-load-test.jmx

# Database Performance
docker-compose exec postgres-auth \
  psql -U admin -d authdb -c "EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'testuser';"
```

---

## 📊 **Monitoring & Observability**

### **📈 Monitoring Stack**

#### **Prometheus Metrics**
```bash
# Prometheus Metriken abrufen
curl http://localhost:8081/actuator/prometheus
curl http://localhost:8082/actuator/prometheus

# Custom Business Metrics
# - Anzahl Registrierungen pro Tag
# - Anzahl erfolgreicher Logins
# - Anzahl Überweisungen
# - Durchschnittliche Response-Zeit
```

#### **Health Checks**
```bash
# Service Health Endpoints
curl http://localhost:8081/api/health
curl http://localhost:8082/api/health

# Detaillierte Health Information
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health

# Database Connection Health
curl http://localhost:8081/actuator/health/db
curl http://localhost:8082/actuator/health/db
```

### **📊 Grafana Dashboards**

#### **System Metrics Dashboard**
- **CPU & Memory Usage** pro Service
- **Database Connections** und Query Performance
- **HTTP Request Rates** und Response Times
- **Error Rates** und Exception Tracking

#### **Business Metrics Dashboard**
- **Daily Active Users**
- **Transaction Volume** und Success Rate
- **Account Creation Rate**
- **API Usage Statistics**

### **🔍 Logging**

#### **Structured Logging**
```yaml
# application.yml
logging:
  level:
    com.bankportal: INFO
    org.springframework.security: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/bankportal.log
```

#### **Log Aggregation**
```bash
# Docker Logs
docker-compose logs -f auth-service
docker-compose logs -f account-service

# Centralized Logging (ELK Stack)
# - Elasticsearch: Log Storage
# - Logstash: Log Processing
# - Kibana: Log Visualization
```

---

## 🔒 **Security**

### **🛡️ Security Features**

#### **Authentication & Authorization**
- **JWT Tokens** mit RS256 Signierung
- **BCrypt Password Hashing** (Strength: 12)
- **Token Expiration** und Refresh Mechanism
- **Role-based Access Control** (RBAC)

#### **API Security**
```java
// SecurityConfig.java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/swagger-ui/**", "/api-docs/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

#### **Database Security**
- **Connection Encryption** (SSL/TLS)
- **Prepared Statements** (SQL Injection Prevention)
- **Database User Isolation** pro Service
- **Regular Security Updates**

### **🔍 Security Scanning**

```bash
# Dependency Vulnerability Scanning
mvn org.owasp:dependency-check-maven:check

# Docker Image Security Scanning
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image bankportal/auth-service:latest

# SAST (Static Application Security Testing)
sonar-scanner -Dsonar.projectKey=bankportal \
  -Dsonar.sources=. \
  -Dsonar.host.url=https://sonarcloud.io
```

### **🔐 Secrets Management**

#### **Development**
```bash
# Environment Variables
export JWT_SECRET="dev-secret-key"
export DB_PASSWORD="admin"

# .env Files
echo "JWT_SECRET=dev-secret-key" > .env.development
```

#### **Production**
```bash
# Kubernetes Secrets
kubectl create secret generic jwt-secret \
  --from-literal=secret=production-jwt-secret

# HashiCorp Vault Integration
vault kv put secret/bankportal \
  jwt_secret=production-jwt-secret \
  db_password=secure-db-password
```

---

## 🚀 **Production Deployment**

### **🏭 Production-Ready Checklist**

#### **✅ Pre-Deployment**
- [ ] **Security Audit** durchgeführt
- [ ] **Performance Tests** bestanden
- [ ] **Backup-System** konfiguriert und getestet
- [ ] **Monitoring** eingerichtet
- [ ] **SSL/TLS Zertifikate** installiert
- [ ] **Environment Variables** gesetzt
- [ ] **Database Migration** Scripts bereit
- [ ] **Rollback-Plan** dokumentiert

#### **🔧 Production Configuration**

```bash
# 1. Production Environment Setup
cp .env.production .env

# 2. SSL Zertifikate konfigurieren
mkdir -p ssl/
# Zertifikate in ssl/ Verzeichnis kopieren

# 3. Production Deployment
docker-compose -f docker-compose-backup.yml up -d

# 4. Health Check
./scripts/deploy-prod.sh --health-check
```

### **🌐 Cloud Deployment**

#### **AWS Deployment**
```bash
# ECS Cluster Setup
aws ecs create-cluster --cluster-name bankportal-prod

# RDS Database Setup
aws rds create-db-instance \
  --db-instance-identifier bankportal-auth-prod \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password secure-password

# Application Load Balancer
aws elbv2 create-load-balancer \
  --name bankportal-alb \
  --subnets subnet-12345 subnet-67890
```

#### **Azure Deployment**
```bash
# Container Instances
az container create \
  --resource-group bankportal-rg \
  --name bankportal-auth \
  --image bankportal/auth-service:latest \
  --ports 8081

# Azure Database for PostgreSQL
az postgres server create \
  --resource-group bankportal-rg \
  --name bankportal-db-server \
  --admin-user admin \
  --admin-password secure-password
```

### **📊 Production Monitoring**

#### **Alerting Rules**
```yaml
# prometheus-alerts.yml
groups:
- name: bankportal-alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
    for: 5m
    annotations:
      summary: "High error rate detected"
      
  - alert: DatabaseConnectionFailure
    expr: up{job="postgres"} == 0
    for: 1m
    annotations:
      summary: "Database connection failed"
      
  - alert: HighMemoryUsage
    expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8
    for: 10m
    annotations:
      summary: "High memory usage detected"
```

#### **SLA Monitoring**
- **Uptime Target**: 99.9% (8.76 Stunden Downtime/Jahr)
- **Response Time**: < 200ms (95th percentile)
- **Error Rate**: < 0.1%
- **Database Performance**: < 50ms Query Time

---

## 🛠️ **Troubleshooting**

### **🔍 Häufige Probleme & Lösungen**

#### **1. 🐳 Docker Issues**

**Problem**: Container startet nicht
```bash
# Diagnose
docker-compose logs auth-service
docker inspect bankportal_auth-service

# Lösung
docker-compose down
docker-compose up -d --build
```

**Problem**: Port bereits belegt
```bash
# Ports überprüfen
netstat -tulpn | grep :8081
lsof -i :8081

# Lösung
docker-compose down
# Oder andere Ports in docker-compose.yml konfigurieren
```

#### **2. 🗄️ Database Issues**

**Problem**: Connection refused
```bash
# Database Status prüfen
docker-compose exec postgres-auth pg_isready -U admin -d authdb

# Connection testen
docker-compose exec postgres-auth \
  psql -U admin -d authdb -c "SELECT version();"

# Logs überprüfen
docker-compose logs postgres-auth
```

**Problem**: Migration Fehler
```bash
# Manual Migration
docker-compose exec postgres-auth \
  psql -U admin -d authdb -f /docker-entrypoint-initdb.d/init.sql

# Schema Reset (Development only!)
docker-compose down -v
docker-compose up -d
```

#### **3. 🔐 Authentication Issues**

**Problem**: JWT Token ungültig
```bash
# Token validieren
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8081/api/auth/validate

# Neuen Token generieren
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}'
```

**Problem**: CORS Fehler
```bash
# CORS Konfiguration prüfen
curl -H "Origin: http://localhost:4200" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: X-Requested-With" \
  -X OPTIONS http://localhost:8081/api/auth/login
```

#### **4. 🌐 Frontend Issues**

**Problem**: API Calls fehlschlagen
```bash
# Proxy Konfiguration prüfen
cat frontend/proxy.conf.json

# Network Tab in Browser DevTools überprüfen
# Service Worker Cache leeren
```

**Problem**: Build Fehler
```bash
# Dependencies neu installieren
cd frontend
rm -rf node_modules package-lock.json
npm install

# Angular CLI aktualisieren
npm install -g @angular/cli@latest
ng update
```

### **🔧 Debug Commands**

#### **Service Debugging**
```bash
# Container Shell Access
docker-compose exec auth-service bash
docker-compose exec postgres-auth psql -U admin -d authdb

# Live Logs
docker-compose logs -f --tail=100 auth-service

# Resource Usage
docker stats

# Network Debugging
docker network ls
docker network inspect bankportal-demo_bank-network
```

#### **Performance Debugging**
```bash
# JVM Heap Dump
docker-compose exec auth-service \
  jcmd 1 GC.run_finalization
docker-compose exec auth-service \
  jcmd 1 VM.classloader_stats

# Database Performance
docker-compose exec postgres-auth \
  psql -U admin -d authdb -c "
    SELECT query, calls, total_time, mean_time 
    FROM pg_stat_statements 
    ORDER BY total_time DESC LIMIT 10;"
```

### **📊 Monitoring & Alerting**

#### **Health Check Script**
```bash
#!/bin/bash
# scripts/health-check.sh

echo "🏥 Bank Portal Health Check"
echo "=========================="

# Auth Service
if curl -f http://localhost:8081/api/health > /dev/null 2>&1; then
    echo "✅ Auth Service: Healthy"
else
    echo "❌ Auth Service: Unhealthy"
fi

# Account Service
if curl -f http://localhost:8082/api/health > /dev/null 2>&1; then
    echo "✅ Account Service: Healthy"
else
    echo "❌ Account Service: Unhealthy"
fi

# Frontend
if curl -f http://localhost:4200 > /dev/null 2>&1; then
    echo "✅ Frontend: Accessible"
else
    echo "❌ Frontend: Inaccessible"
fi

# Database Connections
if docker-compose exec -T postgres-auth pg_isready -U admin -d authdb > /dev/null 2>&1; then
    echo "✅ Auth Database: Connected"
else
    echo "❌ Auth Database: Connection Failed"
fi

if docker-compose exec -T postgres-account pg_isready -U admin -d accountdb > /dev/null 2>&1; then
    echo "✅ Account Database: Connected"
else
    echo "❌ Account Database: Connection Failed"
fi
```

---

## 🎓 **DevOps Best Practices**

### **🔄 CI/CD Pipeline**

#### **GitHub Actions Workflow**
```yaml
# .github/workflows/ci-cd.yml
name: Bank Portal CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Java 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven
    
    - name: Run Tests
      run: |
        cd auth-service && mvn test
        cd ../account-service && mvn test
    
    - name: Build Docker Images
      run: |
        docker build -t bankportal/auth-service:${{ github.sha }} auth-service/
        docker build -t bankportal/account-service:${{ github.sha }} account-service/
    
    - name: Security Scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'bankportal/auth-service:${{ github.sha }}'
        format: 'sarif'
        output: 'trivy-results.sarif'
```

### **📊 Infrastructure as Code**

#### **Docker Compose Templates**
```yaml
# docker-compose.override.yml (für lokale Entwicklung)
version: '3.8'
services:
  auth-service:
    volumes:
      - ./auth-service/src:/app/src
    environment:
      - SPRING_DEVTOOLS_RESTART_ENABLED=true
      - SPRING_PROFILES_ACTIVE=development
  
  account-service:
    volumes:
      - ./account-service/src:/app/src
    environment:
      - SPRING_DEVTOOLS_RESTART_ENABLED=true
      - SPRING_PROFILES_ACTIVE=development
```

#### **Kubernetes Helm Charts**
```yaml
# k8s/helm/bankportal/values.yaml
replicaCount: 2

image:
  repository: bankportal
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: bankportal.example.com
      paths: ["/"]
  tls:
    - secretName: bankportal-tls
      hosts: ["bankportal.example.com"]

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### **🔒 Security Best Practices**

#### **Secrets Management**
```bash
# Kubernetes Secrets
kubectl create secret generic bankportal-secrets \
  --from-literal=jwt-secret=your-jwt-secret \
  --from-literal=db-password=your-db-password

# Docker Secrets (Swarm Mode)
echo "your-jwt-secret" | docker secret create jwt_secret -
echo "your-db-password" | docker secret create db_password -
```

#### **Network Security**
```yaml
# docker-compose-security.yml
version: '3.8'
services:
  auth-service:
    networks:
      - backend
    # Kein direkter Port-Zugriff von außen
  
  nginx:
    ports:
      - "443:443"
    networks:
      - frontend
      - backend
    volumes:
      - ./ssl:/etc/ssl/certs:ro

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # Kein Internet-Zugriff
```

---

## 📚 **Weiterführende Ressourcen**

### **📖 Dokumentation**
- [Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Angular Documentation](https://angular.io/docs)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### **🛠️ Tools & Utilities**
- [Postman Collection](./docs/postman/bankportal-collection.json)
- [Insomnia Workspace](./docs/insomnia/bankportal-workspace.json)
- [JMeter Test Plans](./tests/performance/)
- [Grafana Dashboards](./monitoring/grafana/dashboards/)

### **🎓 Learning Resources**
- [Spring Security JWT Tutorial](https://spring.io/guides/tutorials/spring-boot-oauth2/)
- [Angular Testing Guide](https://angular.io/guide/testing)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Patterns](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)

---

## 🤝 **Contributing**

### **🔄 Development Workflow**
1. **Fork** das Repository
2. **Feature Branch** erstellen: `git checkout -b feature/amazing-feature`
3. **Changes committen**: `git commit -m 'Add amazing feature'`
4. **Branch pushen**: `git push origin feature/amazing-feature`
5. **Pull Request** erstellen

### **📋 Code Standards**
- **Java**: Google Java Style Guide
- **TypeScript**: Angular Style Guide
- **Git Commits**: Conventional Commits
- **Documentation**: Markdown mit Emojis

### **🧪 Testing Requirements**
- **Unit Tests**: Minimum 80% Coverage
- **Integration Tests**: Alle API Endpoints
- **E2E Tests**: Kritische User Journeys
- **Performance Tests**: Load & Stress Testing

---

## 📞 **Support & Kontakt**

### **🐛 Bug Reports**
- **GitHub Issues**: [Issues erstellen](https://github.com/thanhtuanh/bankportal-demo/issues)
- **Template verwenden**: Bug Report Template
- **Logs beifügen**: Relevante Log-Ausgaben

### **💡 Feature Requests**
- **GitHub Discussions**: [Feature Request](https://github.com/thanhtuanh/bankportal-demo/discussions)
- **Use Case beschreiben**: Warum wird das Feature benötigt?
- **Implementation vorschlagen**: Wie könnte es umgesetzt werden?

### **📧 Direkter Kontakt**
- **Email**: dev@bankportal.com
- **LinkedIn**: [Entwickler Profil](https://linkedin.com/in/developer)
- **Twitter**: [@bankportal_dev](https://twitter.com/bankportal_dev)

---

## 📄 **Lizenz**

Dieses Projekt steht unter der **MIT Lizenz** - siehe [LICENSE](LICENSE) Datei für Details.

---

**🎉 Viel Erfolg mit dem Bank Portal! Happy Coding! 🚀**

> *"Moderne Banking-Technologie trifft auf bewährte DevOps-Praktiken"*

---

*Letzte Aktualisierung: Juli 2024 | Version: 2.0.0*
