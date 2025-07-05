# 🐳 Docker Troubleshooting Guide

## 🚨 Häufige Docker-Probleme und Lösungen

### **Problem 1: Maven Image nicht gefunden**
```
ERROR: maven:3.9-openjdk-17-slim: not found
```

**Lösung:**
```bash
# Aktuelle Dockerfiles verwenden OpenJDK + Maven Installation
# Kein separates Maven Image erforderlich

# Falls Problem weiterhin besteht:
docker system prune -a
./start-demo.sh --clean
```

### **Problem 2: JAR-Dateien nicht gefunden**
```
ERROR: COPY target/auth-service-*.jar app.jar
failed to solve: lstat /target: no such file or directory
```

**Lösung:**
```bash
# Multi-Stage Build verwendet - JAR wird im Container gebaut
# Stellen Sie sicher, dass Dockerfiles korrekt sind:

# Prüfen Sie die Dockerfile-Struktur:
cat auth-service/Dockerfile
cat account-service/Dockerfile

# Neustart mit Clean Build:
./start-demo.sh --clean
```

### **Problem 3: Container startet nicht**
```
Container exits with code 1
```

**Diagnose:**
```bash
# Logs überprüfen
docker-compose logs auth-service
docker-compose logs account-service

# Container-Status prüfen
docker-compose ps

# Einzelnen Container debuggen
docker run -it --rm openjdk:17-jdk-slim bash
```

### **Problem 4: Lange Build-Zeiten**
```
Build dauert > 10 Minuten
```

**Optimierung:**
```bash
# 1. Docker Build Cache nutzen
docker-compose build --parallel

# 2. Lokaler Maven Build (falls verfügbar)
cd auth-service && mvn clean package -DskipTests
cd ../account-service && mvn clean package -DskipTests
docker-compose up -d

# 3. Nur geänderte Services neu bauen
docker-compose up -d --build auth-service
```

### **Problem 5: Port bereits belegt**
```
ERROR: Port 8081 is already in use
```

**Lösung:**
```bash
# Ports prüfen
netstat -tulpn | grep :8081
lsof -i :8081

# Prozess beenden
kill -9 $(lsof -t -i:8081)

# Oder andere Ports verwenden (docker-compose.yml ändern)
```

### **Problem 6: Speicher-Probleme**
```
Container killed (OOMKilled)
```

**Lösung:**
```bash
# Docker Memory erhöhen (Docker Desktop)
# Settings → Resources → Memory → 4GB+

# JVM Memory reduzieren (Dockerfile)
ENV JAVA_OPTS="-Xmx256m -Xms128m"

# Container Memory Limits prüfen
docker stats
```

## 🔧 Debug-Commands

### **Container-Debugging**
```bash
# In laufenden Container einloggen
docker exec -it auth-service bash
docker exec -it account-service bash

# Container-Logs live verfolgen
docker-compose logs -f auth-service
docker-compose logs -f account-service

# Alle Logs anzeigen
docker-compose logs --tail=100
```

### **Build-Debugging**
```bash
# Verbose Build
docker-compose build --progress=plain --no-cache

# Einzelnen Service bauen
docker-compose build auth-service

# Build-Cache leeren
docker builder prune -a
```

### **Network-Debugging**
```bash
# Container-Netzwerk prüfen
docker network ls
docker network inspect bankportal-demo_bank-network

# Container-IPs anzeigen
docker inspect auth-service | grep IPAddress
docker inspect account-service | grep IPAddress
```

## 🚀 Performance-Optimierung

### **Build-Performance**
```bash
# .dockerignore erstellen
echo "target/" > auth-service/.dockerignore
echo "node_modules/" > frontend/.dockerignore

# Multi-Stage Build Cache nutzen
docker-compose build --parallel

# Lokale Builds bevorzugen
export DOCKER_BUILDKIT=1
```

### **Runtime-Performance**
```bash
# JVM Tuning
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Container Resources
docker-compose up -d --scale auth-service=2
```

## 🛠️ Vollständiger Reset

### **Alles zurücksetzen**
```bash
# Stoppe alle Container
docker-compose down

# Entferne alle Container, Images, Volumes
docker system prune -a --volumes

# Entferne spezifische Images
docker rmi $(docker images "bankportal*" -q)

# Neustart
./start-demo.sh --clean
```

### **Selektiver Reset**
```bash
# Nur Container neu starten
docker-compose restart

# Nur Services neu bauen
docker-compose up -d --build

# Nur Volumes zurücksetzen
docker-compose down -v
docker-compose up -d
```

## 📊 Monitoring

### **Container-Health**
```bash
# Health Status
docker-compose ps

# Detaillierte Health Info
docker inspect auth-service | grep Health -A 10
docker inspect account-service | grep Health -A 10

# Resource Usage
docker stats --no-stream
```

### **Service-Endpoints**
```bash
# Health Checks
curl http://localhost:8081/api/health
curl http://localhost:8082/api/health

# Service Info
curl http://localhost:8081/actuator/info
curl http://localhost:8082/actuator/info
```

## 🎯 Quick Fixes

```bash
# Standard-Troubleshooting-Workflow:

# 1. Services neu starten
docker-compose restart

# 2. Falls Problem weiterhin besteht
docker-compose down
docker-compose up -d

# 3. Falls immer noch Probleme
docker-compose down -v
./start-demo.sh --clean

# 4. Letzter Ausweg
docker system prune -a --volumes
git pull origin main
./start-demo.sh
```

## 💡 Tipps

- **Geduld bei ersten Build** - Dependencies werden heruntergeladen
- **Docker Desktop Memory** auf mindestens 4GB setzen
- **Logs immer prüfen** bei Problemen
- **Clean Builds** bei merkwürdigen Fehlern
- **Port-Konflikte** durch andere Services prüfen

**🐳 Mit diesen Lösungen sollten alle Docker-Probleme behoben werden können!**
