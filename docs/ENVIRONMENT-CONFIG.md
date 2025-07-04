# 🌍 Environment Configuration Guide

## 📋 Übersicht

Das Bank Portal verwendet **Environment-basierte Konfiguration** für verschiedene Deployment-Umgebungen.

## 🔧 Environment-Dateien

### **Verfügbare Konfigurationen:**

| Datei | Zweck | Status | Verwendung |
|-------|-------|--------|------------|
| `.env.template` | Template für alle Umgebungen | ✅ Verfügbar | Kopiervorlage |
| `.env.development` | Entwicklungsumgebung | ✅ Verfügbar | Lokale Entwicklung |
| `.env.production` | Produktionsumgebung | ✅ Template | Production Deployment |
| `.env` | Lokale Überschreibungen | 🚫 Gitignored | Persönliche Settings |

## 🚀 Setup für Entwicklung

### **1. Environment-Datei erstellen:**
```bash
# Option 1: Template kopieren
cp .env.template .env

# Option 2: Development-Config verwenden
cp .env.development .env

# Option 3: Eigene Konfiguration
nano .env
```

### **2. Werte anpassen:**
```bash
# Wichtige Einstellungen prüfen:
AUTH_DB_PORT=5433          # Auth Service Database
ACCOUNT_DB_PORT=5434       # Account Service Database
JWT_SECRET=your-secret     # JWT Signing Key
FRONTEND_PORT=4200         # Frontend Port
```

## 🔐 Sicherheits-Konfiguration

### **Wichtige Sicherheitseinstellungen:**

#### **JWT Configuration:**
```env
# Development (schwach, nur für Tests)
JWT_SECRET=dev-jwt-secret-key-for-development-only

# Production (stark, mindestens 32 Zeichen)
JWT_SECRET=your-super-secure-jwt-key-min-32-characters-long-random-string
JWT_EXPIRATION=3600  # 1 Stunde für Production
```

#### **Database Security:**
```env
# Development
AUTH_DB_PASSWORD=bankpass123

# Production (starke Passwörter!)
AUTH_DB_PASSWORD=super-secure-random-password-123!@#
```

## 🐳 Docker Integration

### **Docker Compose Verwendung:**
```yaml
# docker-compose.yml verwendet .env automatisch
services:
  auth-service:
    environment:
      - SPRING_DATASOURCE_URL=jdbc:postgresql://${AUTH_DB_HOST}:${AUTH_DB_PORT}/${AUTH_DB_NAME}
      - SPRING_DATASOURCE_USERNAME=${AUTH_DB_USER}
      - SPRING_DATASOURCE_PASSWORD=${AUTH_DB_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
```

### **Environment-spezifische Compose-Dateien:**
```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production  
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

## 🎯 Umgebungs-spezifische Konfiguration

### **Development Environment:**
```env
NODE_ENV=development
DEBUG=true
LOG_LEVEL=DEBUG
SPRING_PROFILES_ACTIVE=dev
SPRING_DEVTOOLS_RESTART_ENABLED=true
```

### **Production Environment:**
```env
NODE_ENV=production
DEBUG=false
LOG_LEVEL=WARN
SPRING_PROFILES_ACTIVE=prod
SSL_ENABLED=true
```

### **Testing Environment:**
```env
NODE_ENV=test
AUTH_DB_NAME=authdb_test
ACCOUNT_DB_NAME=accountdb_test
JWT_SECRET=test-jwt-secret-for-testing-only
```

## 📊 Service-spezifische Konfiguration

### **Frontend (Angular):**
```env
FRONTEND_URL=http://localhost:4200
FRONTEND_PORT=4200
API_BASE_URL=http://localhost:8081
```

### **Auth Service (Spring Boot):**
```env
AUTH_SERVICE_PORT=8081
AUTH_DB_HOST=localhost
AUTH_DB_PORT=5433
JWT_SECRET=your-jwt-secret
SPRING_PROFILES_ACTIVE=dev
```

### **Account Service (Spring Boot):**
```env
ACCOUNT_SERVICE_PORT=8082
ACCOUNT_DB_HOST=localhost
ACCOUNT_DB_PORT=5434
JWT_SECRET=your-jwt-secret
SPRING_PROFILES_ACTIVE=dev
```

## 🔄 CI/CD Integration

### **GitHub Actions Environment:**
```yaml
env:
  NODE_ENV: production
  JWT_SECRET: ${{ secrets.JWT_SECRET }}
  AUTH_DB_PASSWORD: ${{ secrets.AUTH_DB_PASSWORD }}
  ACCOUNT_DB_PASSWORD: ${{ secrets.ACCOUNT_DB_PASSWORD }}
```

### **Secrets Management:**
- **GitHub Secrets** für CI/CD
- **Kubernetes Secrets** für K8s Deployment
- **Docker Secrets** für Swarm Mode
- **HashiCorp Vault** für Enterprise

## ⚠️ Sicherheits-Best Practices

### **DO's:**
- ✅ Verwende starke, zufällige Passwörter
- ✅ Rotiere JWT Secrets regelmäßig
- ✅ Verwende HTTPS in Production
- ✅ Aktiviere SSL für Datenbanken
- ✅ Verwende Environment-spezifische Configs

### **DON'Ts:**
- ❌ Niemals .env Dateien committen
- ❌ Keine Produktions-Secrets in Development
- ❌ Keine schwachen JWT Secrets
- ❌ Keine Default-Passwörter in Production
- ❌ Keine Debug-Modi in Production

## 🛠️ Troubleshooting

### **Häufige Probleme:**

#### **1. Services können nicht verbinden:**
```bash
# Ports prüfen
netstat -tulpn | grep :5433
netstat -tulpn | grep :5434

# Environment-Variablen prüfen
echo $AUTH_DB_PORT
echo $ACCOUNT_DB_PORT
```

#### **2. JWT Token Fehler:**
```bash
# JWT Secret prüfen
echo $JWT_SECRET | wc -c  # Sollte > 32 sein
```

#### **3. Database Connection Fehler:**
```bash
# Database-Verbindung testen
psql -h localhost -p 5433 -U bankuser -d authdb
psql -h localhost -p 5434 -U bankuser -d accountdb
```

## 📈 Monitoring & Logging

### **Environment-basierte Logs:**
```env
# Development - Verbose Logging
LOG_LEVEL=DEBUG
LOG_FORMAT=pretty

# Production - Structured Logging
LOG_LEVEL=WARN
LOG_FORMAT=json
```

**Mit dieser Environment-Konfiguration ist das Bank Portal flexibel für alle Deployment-Szenarien konfigurierbar!** 🚀
