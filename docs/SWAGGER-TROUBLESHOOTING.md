# 🔍 Swagger/OpenAPI Troubleshooting Guide

## 🚨 Problem: 500 Error bei /api-docs

### **Häufige Ursachen:**

#### **1. Datenbankverbindungsprobleme:**
```bash
# Prüfen ob PostgreSQL läuft
docker ps | grep postgres

# Logs prüfen
docker logs postgres-auth
docker logs postgres-account
```

#### **2. Spring Security Konfiguration:**
```java
// Sicherstellen, dass alle Swagger-Endpunkte erlaubt sind:
.requestMatchers("/swagger-ui/**").permitAll()
.requestMatchers("/api-docs/**").permitAll()
.requestMatchers("/v3/api-docs/**").permitAll()
```

#### **3. OpenAPI Dependency-Probleme:**
```xml
<!-- Korrekte Dependency für Spring Boot 3.x -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>
```

## 🔧 Lösungsschritte

### **Schritt 1: Services neu starten**
```bash
# Alle Services stoppen
docker-compose down

# Services neu starten
docker-compose up -d

# Warten bis Services bereit sind
sleep 30
```

### **Schritt 2: Test-Endpunkte prüfen**
```bash
# Auth Service Test
curl http://localhost:8081/api/test/ping

# Account Service Test  
curl http://localhost:8082/api/test/ping

# Swagger Test
curl http://localhost:8081/api/test/swagger-test
curl http://localhost:8082/api/test/swagger-test
```

### **Schritt 3: Swagger URLs prüfen**
```bash
# Korrekte Swagger URLs:
# Auth Service:
http://localhost:8081/swagger-ui/index.html
http://localhost:8081/api-docs

# Account Service:
http://localhost:8082/swagger-ui/index.html
http://localhost:8082/api-docs
```

### **Schritt 4: Logs analysieren**
```bash
# Service-Logs prüfen
docker logs auth-service
docker logs account-service

# Nach Fehlern suchen
docker logs auth-service 2>&1 | grep -i error
docker logs account-service 2>&1 | grep -i error
```

## 🎯 Verbesserte Konfiguration

### **application.properties Ergänzungen:**
```properties
# Detaillierte Fehlerausgabe
server.error.include-message=always
server.error.include-binding-errors=always
server.error.include-stacktrace=on_param

# Swagger-spezifische Einstellungen
springdoc.swagger-ui.tryItOutEnabled=true
springdoc.swagger-ui.filter=true
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html

# Logging für Debugging
logging.level.org.springframework.web=debug
logging.level.org.springdoc=debug
```

## 🧪 Test-Endpunkte

### **Neue Test-Controller hinzugefügt:**

#### **Auth Service Tests:**
- `GET /api/test/ping` - Service-Status
- `GET /api/test/swagger-test` - Swagger-Funktionalität
- `GET /api/test/health-detailed` - Detaillierte Gesundheitsprüfung

#### **Account Service Tests:**
- `GET /api/test/ping` - Service-Status
- `GET /api/test/swagger-test` - Swagger-Funktionalität
- `GET /api/test/health-detailed` - Detaillierte Gesundheitsprüfung

## 🔍 Debugging-Schritte

### **1. Service-Erreichbarkeit:**
```bash
# Basis-Connectivity
curl -v http://localhost:8081/actuator/health
curl -v http://localhost:8082/actuator/health
```

### **2. Swagger-spezifische Tests:**
```bash
# API-Docs direkt testen
curl -v http://localhost:8081/api-docs
curl -v http://localhost:8082/api-docs

# Swagger UI testen
curl -v http://localhost:8081/swagger-ui/index.html
curl -v http://localhost:8082/swagger-ui/index.html
```

### **3. Database-Connectivity:**
```bash
# Database-Verbindung testen
docker exec -it postgres-auth psql -U admin -d authdb -c "SELECT 1;"
docker exec -it postgres-account psql -U admin -d accountdb -c "SELECT 1;"
```

## 🚀 Schnelle Fixes

### **Fix 1: Services neu starten**
```bash
./scripts/restart-services.sh
```

### **Fix 2: Nur Swagger-relevante Services**
```bash
docker-compose restart auth-service account-service
```

### **Fix 3: Kompletter Reset**
```bash
docker-compose down -v
docker-compose up -d
```

## 📊 Erwartete Ergebnisse

### **Erfolgreiche Swagger UI:**
- ✅ Swagger UI lädt ohne Fehler
- ✅ API-Dokumentation ist sichtbar
- ✅ "Try it out" Funktionalität verfügbar
- ✅ Alle Endpunkte dokumentiert

### **Erfolgreiche API-Docs:**
- ✅ `/api-docs` gibt JSON zurück
- ✅ OpenAPI 3.0 Spezifikation
- ✅ Alle Controller dokumentiert
- ✅ Security-Schema definiert

**Mit diesen Fixes sollte Swagger wieder korrekt funktionieren!** 🎉
