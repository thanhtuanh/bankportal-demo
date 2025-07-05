# 🏦 Bank Portal - Quick Reference Guide

## 🚀 **Ein-Klick Demo Start**

```bash
# Repository klonen und Demo starten
git clone https://github.com/thanhtuanh/bankportal-demo.git
cd bankportal-demo
./start-demo.sh

# Alternative: Manuell
docker-compose up -d
```

## 📊 **Service URLs**

| Service | URL | Port |
|---------|-----|------|
| 🌐 **Frontend** | http://localhost:4200 | 4200 |
| 🔐 **Auth Service** | http://localhost:8081 | 8081 |
| 💼 **Account Service** | http://localhost:8082 | 8082 |
| 🔐 **Auth Swagger** | http://localhost:8081/swagger-ui/index.html | 8081 |
| 💼 **Account Swagger** | http://localhost:8082/swagger-ui/index.html | 8082 |
| 📊 **Health Auth** | http://localhost:8081/api/health | 8081 |
| 📊 **Health Account** | http://localhost:8082/api/health | 8082 |

## 🗄️ **Database Connections**

| Database | Host | Port | User | Password | Database |
|----------|------|------|------|----------|----------|
| **Auth DB** | localhost | 5433 | admin | admin | authdb |
| **Account DB** | localhost | 5434 | admin | admin | accountdb |

```bash
# Database Connection Commands
docker exec -it postgres-auth psql -U admin -d authdb
docker exec -it postgres-account psql -U admin -d accountdb
```

## 🧪 **Demo API Tests**

### **1. Benutzer registrieren**
```bash
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}'
```

### **2. JWT Token erhalten**
```bash
TOKEN=$(curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' \
  | jq -r '.token')
```

### **3. Konto erstellen**
```bash
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"owner": "demo", "balance": 1000.0}'
```

### **4. Konten anzeigen**
```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8082/api/accounts
```

### **5. Geld überweisen**
```bash
curl -X POST http://localhost:8082/api/accounts/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fromAccountId": 1, "toAccountId": 2, "amount": 100.0}'
```

## 🐳 **Docker Commands**

### **Standard Commands**
```bash
# Demo starten
docker-compose up -d

# Production mit Backup
docker-compose -f docker-compose-backup.yml up -d

# Services stoppen
docker-compose down

# Mit Datenbereinigung
docker-compose down -v

# Logs anzeigen
docker-compose logs -f

# Einzelne Services
docker-compose logs -f auth-service
docker-compose logs -f account-service
```

### **Container Management**
```bash
# Container Status
docker-compose ps

# In Container einloggen
docker exec -it auth-service bash
docker exec -it account-service bash

# Resource Usage
docker stats
```

## 🔧 **Development Commands**

### **Lokale Entwicklung**
```bash
# Backend Services
cd auth-service && mvn spring-boot:run
cd account-service && mvn spring-boot:run

# Frontend
cd frontend && npm start

# Tests
cd auth-service && mvn test
cd account-service && mvn test
cd frontend && npm test
```

### **Build Commands**
```bash
# Backend Build
cd auth-service && mvn clean package
cd account-service && mvn clean package

# Frontend Build
cd frontend && npm run build:prod

# Docker Images
docker-compose build
```

## ☸️ **Kubernetes Commands**

### **Minikube Setup**
```bash
# Minikube starten
minikube start --cpus=4 --memory=8192

# Dashboard
minikube dashboard

# Services deployen
kubectl apply -f k8s/dev/
```

### **Kubernetes Management**
```bash
# Status
kubectl get pods,services,ingress

# Logs
kubectl logs -f deployment/auth-service
kubectl logs -f deployment/account-service

# Port Forwarding
kubectl port-forward service/auth-service 8081:8081
kubectl port-forward service/account-service 8082:8082
```

## 🔍 **Troubleshooting**

### **Häufige Probleme**
```bash
# Services nicht erreichbar
docker-compose restart

# Port bereits belegt
netstat -tulpn | grep :8081
lsof -i :8081

# Database Connection
docker-compose exec postgres-auth pg_isready -U admin

# Logs überprüfen
docker-compose logs auth-service
docker-compose logs account-service
```

### **Health Checks**
```bash
# Service Health
curl http://localhost:8081/api/health
curl http://localhost:8082/api/health

# Database Health
docker exec postgres-auth pg_isready -U admin -d authdb
docker exec postgres-account pg_isready -U admin -d accountdb
```

## 🛑 **Demo stoppen**

```bash
# Services stoppen
docker-compose down

# Mit Datenbereinigung
docker-compose down -v

# Alle Docker Resources bereinigen
docker system prune -a
```

## 📚 **Weitere Dokumentation**

- **README.md** - Hauptdokumentation
- **README.dev.md** - Entwickler-Guide
- **Swagger UI** - API Dokumentation
  - Auth: http://localhost:8081/swagger-ui/index.html
  - Account: http://localhost:8082/swagger-ui/index.html

---

**🎉 Viel Spaß mit dem Bank Portal Demo!**
