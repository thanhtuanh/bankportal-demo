# 🏦 Bank Portal - Moderne Banking-Plattform

> **Enterprise-Grade Banking-Lösung**  
> Java 17 • Spring Boot 3.4 • Angular 18 • PostgreSQL 15 • Docker • Kubernetes

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.java.net/projects/jdk/17/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Angular](https://img.shields.io/badge/Angular-18-red.svg)](https://angular.io/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

---

## 🚀 **Schnellstart**

```bash
git clone https://github.com/thanhtuanh/bankportal-demo.git
cd bankportal-demo
./start-demo.sh
```

**Bereit in 2 Minuten!** → http://localhost:4200

---

## 🎯 **Hauptfunktionen**

| Komponente | Technologie | Port | Beschreibung |
|-----------|------------|------|-------------|
| **Frontend** | Angular 18 | 4200 | Moderne Banking-Oberfläche |
| **Auth API** | Spring Boot | 8081 | JWT-Authentifizierung |
| **Account API** | Spring Boot | 8082 | Kontenverwaltung |
| **Datenbank** | PostgreSQL 15 | 5433/5434 | ACID-Transaktionen |

---

## 🏗️ **Architektur**

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

**Microservices-Architektur** • **JWT-Sicherheit** • **Docker-Containerisiert**

---

## 💼 **Demo-Workflow**

### 1. **Benutzerregistrierung & Anmeldung**
```bash
curl -X POST http://localhost:8081/api/auth/register \
  -d '{"username": "demo", "password": "demo123"}'
```

### 2. **Kontenverwaltung**
```bash
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"owner": "demo", "balance": 1000.0}'
```

### 3. **Geldtransfer**
```bash
curl -X POST http://localhost:8082/api/accounts/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"fromAccountId": 1, "toAccountId": 2, "amount": 100.0}'
```

---

## 🔧 **Entwicklung**

### **Lokales Setup**
```bash
# Entwicklung
docker-compose up -d

# Produktion mit Backup
docker-compose -f docker-compose-backup.yml up -d

# Kubernetes Demo
./scripts/start-k8s-demo.sh
```

### **Technologie-Stack**
- **Backend:** Java 17, Spring Boot 3.4, Spring Security
- **Frontend:** Angular 18, TypeScript, RxJS
- **Datenbank:** PostgreSQL 15, JPA/Hibernate
- **DevOps:** Docker, Kubernetes, GitHub Actions
- **Sicherheit:** JWT, BCrypt, CORS-Schutz

---

## 🚀 **Produktionsbereit**

### **Enterprise-Funktionen**
- ✅ **Microservices-Architektur**
- ✅ **JWT-Authentifizierung & Autorisierung**
- ✅ **ACID-Datenbanktransaktionen**
- ✅ **Automatisierte Sicherung & Wiederherstellung**
- ✅ **Health Checks & Monitoring**
- ✅ **CI/CD-Pipeline**
- ✅ **Kubernetes-Deployment**
- ✅ **Sicherheits-Best Practices**

### **Deployment-Optionen**
- **Docker Compose** - Lokale Entwicklung
- **Kubernetes** - Container-Orchestrierung
- **Cloud Ready** - AWS, Azure, GCP kompatibel

---

## 📚 **Dokumentation**

| Anleitung | Beschreibung |
|-----------|-------------|
| [Frontend-Anleitung](docs/FRONTEND-GUIDE.md) | Web-App Benutzerhandbuch |
| [API-Tests](docs/API-TESTING.md) | REST-API Beispiele |
| [Entwickler-Anleitung](README.dev.md) | Technische Dokumentation |
| [GitHub Secrets](docs/GITHUB-SECRETS-SETUP.md) | Automatisierte Secrets-Verwaltung |
| [Kubernetes-Lernen](docs/KUBERNETES-LEARNING-GUIDE.md) | K8s Lernpfad |
| [Schnellreferenz](docs/QUICK-REFERENCE.md) | Wichtige Befehle |

---

## 🎓 **DevOps-Showcase**

Dieses Projekt demonstriert:
- **Moderne Java-Entwicklung** (Spring Boot 3.4, Java 17)
- **Frontend-Engineering** (Angular 18, TypeScript)
- **Microservices-Design** (Service-Trennung, API Gateway)
- **Datenbank-Management** (PostgreSQL, Transaktionen, Backup)
- **Container-Technologie** (Docker, Kubernetes)
- **CI/CD-Implementierung** (GitHub Actions, Automatisierte Tests)
- **Sicherheits-Implementierung** (JWT, Secrets-Management)
- **Produktions-Betrieb** (Monitoring, Health Checks, Recovery)

---

## 🛠️ **Schnellbefehle**

```bash
# Demo starten
./start-demo.sh

# Kubernetes Demo
./scripts/start-k8s-demo.sh

# Services anzeigen
docker-compose ps

# Health Checks
curl http://localhost:8081/api/health
curl http://localhost:8082/api/health

# Logs anzeigen
docker-compose logs -f

# Demo stoppen
docker-compose down
./scripts/stop-k8s-demo.sh
```

---

## 📞 **Kontakt**

- **GitHub:** [thanhtuanh/bankportal-demo](https://github.com/thanhtuanh/bankportal-demo)
- **Issues:** [Bugs melden](https://github.com/thanhtuanh/bankportal-demo/issues)
- **Lizenz:** MIT

---

**🎯 Enterprise-Grade Banking-Plattform, die moderne Entwicklungspraktiken und produktionsbereite Architektur demonstriert.**
