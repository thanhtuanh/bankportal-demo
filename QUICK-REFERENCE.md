# 🚀 Bank Portal - Quick Reference

## 📋 **Schnellstart Commands**

### **Lokale Entwicklung**
```bash
# Schneller Start
docker-compose up -d

# Mit frischen Images
./scripts/deploy-local.sh

# CI/CD lokal testen
./scripts/ci-local-quick.sh

# API Tests
./scripts/test-api.sh
```

### **Kubernetes**
```bash
# Minikube starten
minikube start --memory=4096 --cpus=2

# Deployment
kubectl apply -f k8s/dev/

# Status
./scripts/monitor-k8s.sh

# Port-Forward
kubectl port-forward service/bankportal-frontend-service 4200:80 -n bankportal-dev
```

### **Monitoring**
```bash
# Prometheus & Grafana starten
docker run -d --name prometheus -p 9090:9090 prom/prometheus:latest
docker run -d --name grafana -p 3000:3000 -e GF_SECURITY_ADMIN_PASSWORD=admin grafana/grafana:latest
```

### **Backup & Security**
```bash
# Backup erstellen
./scripts/backup-system.sh backup

# SSL Zertifikate generieren
./scripts/generate-ssl.sh

# Security Scan
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image bankportal-demo-auth-service:latest
```

## 🌐 **URLs nach Deployment**

| Service | URL | Beschreibung |
|---------|-----|--------------|
| **Frontend** | http://localhost:4200 | Angular SPA |
| **Auth API** | http://localhost:8081 | Authentifizierung |
| **Account API** | http://localhost:8082 | Kontenverwaltung |
| **Auth Swagger** | http://localhost:8081/swagger-ui.html | API Dokumentation |
| **Account Swagger** | http://localhost:8082/swagger-ui.html | API Dokumentation |
| **Prometheus** | http://localhost:9090 | Metriken |
| **Grafana** | http://localhost:3000 | Dashboards (admin/admin) |

## 🔧 **Troubleshooting**

### **Container Probleme**
```bash
# Logs anzeigen
docker-compose logs -f

# Container neu starten
docker-compose restart <service-name>

# Container Shell
docker exec -it <container-name> /bin/bash
```

### **Kubernetes Probleme**
```bash
# Pod Logs
kubectl logs -f <pod-name> -n bankportal-dev

# Pod beschreiben
kubectl describe pod <pod-name> -n bankportal-dev

# Events anzeigen
kubectl get events -n bankportal-dev --sort-by='.lastTimestamp'
```

### **Häufige Fixes**
```bash
# Ports freigeben
sudo lsof -ti:4200 | xargs kill -9

# Docker bereinigen
docker system prune -f

# Volumes bereinigen
docker volume prune -f
```

## 📊 **Service Status prüfen**

### **Health Checks**
```bash
# Auth Service
curl http://localhost:8081/actuator/health

# Account Service
curl http://localhost:8082/actuator/health

# Frontend
curl http://localhost:4200
```

### **API Tests**
```bash
# Benutzer registrieren
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}'

# Anmelden
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}'

# Konten abrufen (mit JWT Token)
curl -H "Authorization: Bearer <token>" http://localhost:8082/api/accounts
```

## 🎯 **Deployment Checkliste**

### **Vor dem Deployment**
- [ ] Tests laufen durch (`./scripts/ci-local-quick.sh`)
- [ ] Docker Images gebaut
- [ ] Environment Variablen gesetzt
- [ ] Datenbank verfügbar

### **Nach dem Deployment**
- [ ] Health Checks OK
- [ ] API Tests erfolgreich
- [ ] Frontend erreichbar
- [ ] Logs ohne Fehler

### **Production Ready**
- [ ] SSL Zertifikate konfiguriert
- [ ] Monitoring eingerichtet
- [ ] Backup konfiguriert
- [ ] Security Scan durchgeführt

## 🚨 **Notfall Commands**

### **Alles neu starten**
```bash
docker-compose down
docker system prune -f
./scripts/deploy-local.sh
```

### **Backup wiederherstellen**
```bash
./scripts/backup-system.sh list
./scripts/backup-system.sh restore <backup-date>
```

### **Kubernetes Reset**
```bash
kubectl delete namespace bankportal-dev
kubectl apply -f k8s/dev/
```

---

**💡 Tipp:** Für detaillierte Informationen siehe [README.dev.md](README.dev.md)
