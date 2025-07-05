# 🏥 Health Check Guide

## 📋 Übersicht

Alle Services im Bank Portal haben Health Check Endpoints für Monitoring und Docker Health Checks.

## 🔍 Health Check Endpoints

### **Auth Service (Port 8081)**
```bash
# Basic Health Check
curl http://localhost:8081/api/health

# Erwartete Antwort:
{
  "status": "UP",
  "service": "auth-service",
  "timestamp": "2025-07-05T10:30:00",
  "version": "1.0.0",
  "description": "Bank Portal Authentication Service"
}
```

### **Account Service (Port 8082)**
```bash
# Basic Health Check
curl http://localhost:8082/api/health

# Erwartete Antwort:
{
  "status": "UP",
  "service": "account-service",
  "timestamp": "2025-07-05T10:30:00",
  "version": "1.0.0",
  "description": "Bank Portal Account Management Service"
}
```

### **Service Information**
```bash
# Detaillierte Service-Info (Account Service)
curl http://localhost:8082/api/info

# Erwartete Antwort:
{
  "service": "account-service",
  "version": "1.0.0",
  "description": "Bank Portal Account Management Service",
  "features": [
    "Account Management",
    "Money Transfer", 
    "Balance Inquiry",
    "Transaction History"
  ],
  "timestamp": "2025-07-05T10:30:00"
}
```

## 🐳 Docker Health Checks

### **Container Health Status**
```bash
# Alle Container Health Status
docker-compose ps

# Erwartete Ausgabe:
NAME              COMMAND                  SERVICE           STATUS
auth-service      "sh -c 'java $JAVA_O…"   auth-service      Up (healthy)
account-service   "sh -c 'java $JAVA_O…"   account-service   Up (healthy)
frontend          "/docker-entrypoint.…"   frontend          Up (healthy)
```

### **Detaillierte Health Information**
```bash
# Health Details für einzelnen Container
docker inspect auth-service | grep -A 10 Health

# Health Logs anzeigen
docker inspect auth-service | jq '.[0].State.Health'
```

## 🔧 Health Check Konfiguration

### **Dockerfile Health Checks**
```dockerfile
# Auth Service Dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8081/api/health || exit 1

# Account Service Dockerfile  
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8082/api/health || exit 1
```

### **Docker Compose Health Checks**
```yaml
# docker-compose.yml
services:
  auth-service:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

## 🚨 Troubleshooting

### **Health Check Failures**

**Problem:** Health Check gibt 403 Forbidden
```bash
# Lösung: Spring Security Konfiguration prüfen
# /api/health muss in SecurityConfig freigegeben sein:
.requestMatchers("/api/health").permitAll()
```

**Problem:** Health Check gibt 404 Not Found
```bash
# Lösung: HealthController prüfen
# Controller muss @RestController und @RequestMapping("/api") haben
```

**Problem:** Container wird als "unhealthy" markiert
```bash
# Diagnose: Health Check Logs prüfen
docker inspect auth-service | jq '.[0].State.Health.Log'

# Manueller Test:
docker exec auth-service curl -f http://localhost:8081/api/health
```

### **Service Startup Issues**

**Problem:** Service startet nicht
```bash
# Logs prüfen
docker-compose logs auth-service
docker-compose logs account-service

# Health Check manuell testen
curl -v http://localhost:8081/api/health
curl -v http://localhost:8082/api/health
```

**Problem:** Lange Startup-Zeiten**
```bash
# start_period in Health Check erhöhen
HEALTHCHECK --start-period=120s

# Oder in docker-compose.yml:
healthcheck:
  start_period: 120s
```

## 📊 Monitoring Integration

### **Prometheus Health Metrics**
```bash
# Actuator Health Endpoint
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health

# Prometheus Metrics
curl http://localhost:8081/actuator/prometheus | grep health
curl http://localhost:8082/actuator/prometheus | grep health
```

### **Custom Health Indicators**
```java
// Beispiel: Database Health Indicator
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    @Override
    public Health health() {
        try {
            // Database Connection Test
            return Health.up()
                .withDetail("database", "PostgreSQL")
                .withDetail("status", "Connected")
                .build();
        } catch (Exception e) {
            return Health.down()
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}
```

## 🎯 Best Practices

### **Health Check Design**
- **Lightweight**: Schnelle Antwortzeiten (< 1 Sekunde)
- **Meaningful**: Prüft kritische Abhängigkeiten
- **Consistent**: Einheitliches Response-Format
- **Secure**: Keine sensiblen Informationen preisgeben

### **Docker Health Checks**
- **start_period**: Genug Zeit für Service-Startup
- **interval**: Nicht zu häufig (30s ist gut)
- **retries**: 3-5 Versuche vor "unhealthy"
- **timeout**: Kurz genug für schnelle Erkennung

### **Monitoring Integration**
- **Prometheus**: Metrics für Health Status
- **Grafana**: Dashboards für Health Trends
- **Alerting**: Benachrichtigungen bei Health Failures

## 🧪 Test-Szenarien

### **Automatisierte Health Check Tests**
```bash
#!/bin/bash
# health-check-test.sh

echo "🏥 Testing Health Checks..."

# Test Auth Service
if curl -f -s http://localhost:8081/api/health > /dev/null; then
    echo "✅ Auth Service: Healthy"
else
    echo "❌ Auth Service: Unhealthy"
fi

# Test Account Service  
if curl -f -s http://localhost:8082/api/health > /dev/null; then
    echo "✅ Account Service: Healthy"
else
    echo "❌ Account Service: Unhealthy"
fi

# Test Frontend
if curl -f -s http://localhost:4200 > /dev/null; then
    echo "✅ Frontend: Healthy"
else
    echo "❌ Frontend: Unhealthy"
fi
```

### **Load Testing Health Endpoints**
```bash
# Apache Bench Test
ab -n 1000 -c 10 http://localhost:8081/api/health

# Erwartung: Alle Requests erfolgreich, niedrige Latenz
```

## 📚 Weiterführende Informationen

- [Spring Boot Actuator Health](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.endpoints.health)
- [Docker Health Checks](https://docs.docker.com/engine/reference/builder/#healthcheck)
- [Prometheus Health Monitoring](https://prometheus.io/docs/guides/multi-target-exporter/)

---

**🏥 Mit diesen Health Checks haben Sie vollständige Übersicht über den Status aller Services!**
