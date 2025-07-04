# 🚀 CI/CD Pipeline Guide

## 📋 Übersicht

Das Bank Portal verwendet **eine einzige, umfassende CI/CD Pipeline** für alle Builds und Deployments.

## 🔧 Pipeline-Konfiguration

### **Aktive Pipeline:**
- **Datei:** `.github/workflows/ci-cd.yml`
- **Name:** "Bank Portal CI/CD Pipeline"
- **Status:** ✅ Aktiv

### **Trigger:**
- **Push** zu Branches: main, develop, k8s, stand-1, stand-2
- **Pull Requests** zu main
- **Manual Dispatch** mit Environment-Auswahl

## 📊 Pipeline-Jobs

| Job | Beschreibung | Dauer | Dependencies |
|-----|--------------|-------|--------------|
| **🌐 Frontend Build** | Angular Build mit npm | ~3 min | - |
| **🔐 Auth Service** | Spring Boot + PostgreSQL Tests | ~4 min | - |
| **💼 Account Service** | Spring Boot + PostgreSQL Tests | ~4 min | - |
| **🐳 Docker Build** | Multi-Service Container Build | ~5 min | Alle Builds |
| **🧪 Integration Tests** | E2E Tests mit docker-compose | ~3 min | Docker Build |
| **📊 Deployment Report** | Status Summary | ~1 min | Alle Jobs |

**Gesamtdauer:** ~15-20 Minuten

## 🎯 Pipeline-Features

### **✅ Was die Pipeline macht:**
- **Frontend:** npm ci, production build, artifact upload
- **Backend:** Maven build, PostgreSQL integration tests
- **Docker:** Multi-platform container builds
- **Testing:** Health checks, Swagger validation
- **Reporting:** Comprehensive GitHub Step Summary

### **🔧 Technische Details:**
- **Node.js:** Version 18 mit npm caching
- **Java:** Version 17 mit Maven caching
- **PostgreSQL:** Separate Test-DBs (Ports 5432, 5433)
- **Docker:** Buildx für Multi-Platform Support
- **Artifacts:** 30-Tage Retention

## 🚨 Troubleshooting

### **Häufige Probleme:**

#### **1. npm ci Fehler:**
```bash
# Lösung: package-lock.json muss existieren
npm install  # Generiert package-lock.json
git add frontend/package-lock.json
git commit -m "Add package-lock.json"
```

#### **2. Maven Build Fehler:**
```bash
# Lösung: Java Version prüfen
mvn -version  # Sollte Java 17 sein
```

#### **3. Docker Build Fehler:**
```bash
# Lösung: Artifacts prüfen
ls -la auth-service/target/
ls -la account-service/target/
ls -la frontend/dist/
```

## 📈 Pipeline-Optimierung

### **Performance-Tipps:**
- **Caching:** npm und Maven Caches aktiviert
- **Parallel Jobs:** Frontend und Backend parallel
- **Artifact Reuse:** Builds zwischen Jobs geteilt
- **Conditional Runs:** Docker nur bei Push/Manual

### **Monitoring:**
- **GitHub Actions Tab:** Live-Status
- **Step Summary:** Detaillierte Reports
- **Artifacts:** Download verfügbar

## 🎯 Für Entwickler

### **Lokale Entwicklung:**
```bash
# Frontend
cd frontend && npm install && npm run build:prod

# Auth Service
cd auth-service && mvn clean package -DskipTests

# Account Service  
cd account-service && mvn clean package -DskipTests

# Docker Build
docker-compose build
```

### **Pipeline testen:**
```bash
# Manual Trigger über GitHub UI
# Oder Push zu main Branch
git push origin main
```

## 🔄 Pipeline-Historie

- **v1.0:** Basis-Pipeline mit SonarCloud
- **v2.0:** SonarCloud deaktiviert (Konfigurationsprobleme)
- **v3.0:** npm ci Fehler behoben
- **v4.0:** Multiple Pipeline-Trigger Problem behoben
- **v5.0:** ✅ **Aktuelle Version - Single Pipeline**

**Die Pipeline ist jetzt optimiert für eine einzige, zuverlässige Ausführung pro Trigger!** 🎉
