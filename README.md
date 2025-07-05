# 🏦 Bank Portal - Modern Banking Platform

> **Enterprise-Grade Banking-Lösung mit modernsten Technologien**  
> Java 17 + Spring Boot 3.4 + Angular 18 + PostgreSQL 15 + Docker + Kubernetes

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.java.net/projects/jdk/17/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Angular](https://img.shields.io/badge/Angular-18-red.svg)](https://angular.io/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Production Ready](https://img.shields.io/badge/Production-Ready-success.svg)](#-production-features)

---

## 🚀 **Ein-Klick Demo Start**

```bash
# Repository klonen und Demo starten
git clone https://github.com/thanhtuanh/bankportal-demo.git
cd bankportal-demo
./start-demo.sh
```

**Das war's! 🎉** Nach 2-3 Minuten ist das komplette Banking-System bereit.

### **📊 Demo URLs**
- 🌐 **Frontend**: http://localhost:4200
- 🔐 **Auth API**: http://localhost:8081/swagger-ui/index.html
- 💼 **Account API**: http://localhost:8082/swagger-ui/index.html

---

## 📋 **Inhaltsverzeichnis**

### **🎯 Schnellstart**
- [Ein-Klick Demo](#-ein-klick-demo-start) - Sofort loslegen
- [Frontend Bedienung](docs/FRONTEND-GUIDE.md) - Web-App Anleitung
- [API Testing](docs/API-TESTING.md) - Swagger & curl Beispiele
- [Quick Reference](QUICK-REFERENCE.md) - Wichtigste Commands

### **🏗️ Architektur & Technologie**
- [System-Architektur](#-system-architektur) - Überblick
- [Technologie-Stack](#-technologie-stack) - Details
- [Microservices Design](docs/MICROSERVICES-ARCHITECTURE.md) - Detaillierte Architektur
- [Database Design](docs/DATABASE-DESIGN.md) - Datenbank-Schema

### **🔧 Development**
- [Development Setup](README.dev.md) - Vollständiger Entwickler-Guide
- [Local Development](docs/LOCAL-DEVELOPMENT.md) - Ohne Docker
- [Testing Guide](docs/TESTING-GUIDE.md) - Unit, Integration, E2E
- [Contributing](docs/CONTRIBUTING.md) - Beitrag leisten

### **🚀 Deployment**
- [Docker Deployment](#-docker-deployment) - Standard & Production
- [Kubernetes Guide](docs/KUBERNETES-DEPLOYMENT.md) - K8s Setup
- [Cloud Deployment](docs/CLOUD-DEPLOYMENT.md) - AWS, Azure, GCP
- [CI/CD Pipeline](docs/CICD-GUIDE.md) - GitHub Actions

### **🔒 Security & Operations**
- [Security Guide](docs/SECURITY-GUIDE.md) - Sicherheits-Best Practices
- [GitHub Secrets](docs/GITHUB-SECRETS-SETUP.md) - Automatische Secrets
- [Monitoring](docs/MONITORING-GUIDE.md) - Prometheus & Grafana
- [Backup & Recovery](docs/BACKUP-RECOVERY.md) - Daten-Sicherung

---

## 🏗️ **System-Architektur**

### **🎨 Überblick**
```
Frontend (Angular) → API Gateway → Microservices → Databases
     ↓                   ↓              ↓           ↓
  Port 4200         nginx Proxy    Auth + Account  PostgreSQL
```

### **📊 Services**
| Service | Port | Beschreibung | Swagger |
|---------|------|--------------|---------|
| 🌐 **Frontend** | 4200 | Angular SPA | - |
| 🔐 **Auth Service** | 8081 | JWT Authentication | [Swagger UI](http://localhost:8081/swagger-ui/index.html) |
| 💼 **Account Service** | 8082 | Account Management | [Swagger UI](http://localhost:8082/swagger-ui/index.html) |
| 🗄️ **Auth DB** | 5433 | PostgreSQL | - |
| 🗄️ **Account DB** | 5434 | PostgreSQL | - |

**📚 Detaillierte Architektur:** [Microservices Design](docs/MICROSERVICES-ARCHITECTURE.md)

---

## 💻 **Technologie-Stack**

### **Backend**
- **Java 17** - LTS Version mit Performance-Optimierungen
- **Spring Boot 3.4** - Enterprise Java Framework
- **Spring Security** - JWT Authentication
- **PostgreSQL 15** - ACID-konforme Datenbank
- **SpringDoc OpenAPI** - API Dokumentation

### **Frontend**
- **Angular 18** - Enterprise SPA Framework
- **TypeScript** - Typsichere Entwicklung
- **RxJS** - Reactive Programming
- **Responsive Design** - Multi-Device Support

### **DevOps**
- **Docker** - Containerisierung
- **Kubernetes** - Container-Orchestrierung
- **GitHub Actions** - CI/CD Pipeline
- **Prometheus & Grafana** - Monitoring

**📚 Vollständige Details:** [Technology Deep Dive](docs/TECHNOLOGY-STACK.md)

---

## 🐳 **Docker Deployment**

### **🔧 Development (Standard)**
```bash
# Schneller Start für Entwicklung
docker-compose up -d
```

### **🚀 Production (mit Backup)**
```bash
# Production-Ready mit Backup-System
docker-compose -f docker-compose-backup.yml up -d
```

### **📊 Features Vergleich**
| Feature | Development | Production |
|---------|-------------|------------|
| **Backup System** | ❌ | ✅ WAL-Archiving |
| **Monitoring** | Basic | ✅ Prometheus/Grafana |
| **Log Rotation** | ❌ | ✅ Automatisch |
| **Health Checks** | Basic | ✅ Erweitert |
| **Restart Policies** | ❌ | ✅ Auto-Restart |

**📚 Detaillierte Anleitung:** [Docker Deployment Guide](docs/DOCKER-DEPLOYMENT.md)

---

## 🧪 **Demo-Szenario (5 Minuten)**

### **1. 👤 Benutzer-Registrierung**
```bash
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}'
```

### **2. 🔐 JWT Token erhalten**
```bash
TOKEN=$(curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' \
  | jq -r '.token')
```

### **3. 💼 Konto erstellen**
```bash
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"owner": "demo", "balance": 1000.0}'
```

### **4. 💸 Geld überweisen**
```bash
curl -X POST http://localhost:8082/api/accounts/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fromAccountId": 1, "toAccountId": 2, "amount": 100.0}'
```

**📚 Vollständige API-Beispiele:** [API Testing Guide](docs/API-TESTING.md)

---

## 🌐 **Frontend Bedienung**

### **📱 Web-App Features**
- ✅ **Benutzer-Registrierung** und sicherer Login
- ✅ **Dashboard** mit Konten-Übersicht
- ✅ **Konto-Erstellung** mit Startguthaben
- ✅ **Geld-Transfers** zwischen Konten
- ✅ **Transaktionshistorie** mit Details
- ✅ **Responsive Design** für alle Geräte

### **🎯 Schnellstart-Workflow**
1. **http://localhost:4200** öffnen
2. **Registrieren** (demo/demo123)
3. **Konto erstellen** (1000€ Startguthaben)
4. **Geld überweisen** zwischen Konten

**📚 Detaillierte Bedienungsanleitung:** [Frontend Guide](docs/FRONTEND-GUIDE.md)

---

## 🔒 **Production Features**

### **🛡️ Security**
- **JWT Authentication** mit BCrypt-Hashing
- **CORS Protection** und Rate Limiting
- **SQL Injection Prevention** durch JPA
- **Environment-basierte Secrets** Management

### **📊 Monitoring & Observability**
- **Health Checks** für alle Services
- **Prometheus Metrics** Collection
- **Grafana Dashboards** für Visualisierung
- **Structured Logging** mit JSON Format

### **💾 Backup & Recovery**
- **Automatische Backups** (täglich um 2 Uhr)
- **WAL-Archiving** für Point-in-Time Recovery
- **30-Tage Retention** Policy
- **Backup-Monitoring** und Alerting

### **☸️ Cloud-Ready**
- **Kubernetes Manifeste** für Container-Orchestrierung
- **Helm Charts** für Package Management
- **Multi-Cloud Support** (AWS, Azure, GCP)
- **Auto-Scaling** Konfiguration

**📚 Production Deployment:** [Production Guide](docs/PRODUCTION-DEPLOYMENT.md)

---

## 🎓 **DevOps-Lernziele**

### **🔧 Praktische DevOps-Erfahrung**
Dieses Projekt dient als **DevOps-Lernplattform** und demonstriert:

- **Container-Orchestrierung** mit Docker & Kubernetes
- **CI/CD Pipelines** mit GitHub Actions
- **Infrastructure as Code** mit Terraform
- **Monitoring & Observability** mit Prometheus/Grafana
- **Security Best Practices** für Production

### **📈 Geplante Erweiterungen**
- **Multi-Environment Setup** (Dev/Staging/Prod)
- **Chaos Engineering** für Resilience Testing
- **Performance Testing** mit JMeter
- **Cost Optimization** Strategien

**📚 DevOps Deep Dive:** [DevOps Learning Path](docs/DEVOPS-LEARNING.md)

---

## 🤝 **Community & Support**

### **📚 Dokumentation**
- **[Development Guide](README.dev.md)** - Vollständiger Entwickler-Guide
- **[Quick Reference](QUICK-REFERENCE.md)** - Wichtigste Commands
- **[API Documentation](docs/API-DOCUMENTATION.md)** - REST API Details
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Häufige Probleme

### **🐛 Issues & Support**
- **[GitHub Issues](https://github.com/thanhtuanh/bankportal-demo/issues)** - Bug Reports
- **[Discussions](https://github.com/thanhtuanh/bankportal-demo/discussions)** - Feature Requests
- **[Contributing Guide](docs/CONTRIBUTING.md)** - Beitrag leisten

### **📊 Project Stats**
- **Languages:** Java, TypeScript, YAML, Shell
- **Architecture:** Microservices, Event-Driven
- **Deployment:** Docker, Kubernetes, Cloud-Native
- **Testing:** Unit, Integration, E2E, Performance

---

## 📄 **Lizenz**

Dieses Projekt steht unter der **MIT Lizenz** - siehe [LICENSE](LICENSE) für Details.

---

## 🎉 **Quick Start Zusammenfassung**

```bash
# 1. Klonen & Starten
git clone https://github.com/thanhtuanh/bankportal-demo.git
cd bankportal-demo
./start-demo.sh

# 2. URLs öffnen
open http://localhost:4200                           # Frontend
open http://localhost:8081/swagger-ui/index.html     # Auth API
open http://localhost:8082/swagger-ui/index.html     # Account API

# 3. Demo stoppen
docker-compose down
```

**🚀 Viel Spaß mit dem Bank Portal! Happy Banking! 🏦**

---

*Letzte Aktualisierung: Juli 2024 | Version: 2.1.0*
