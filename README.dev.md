# 🚀 Bank Portal - Vollständiges DevOps Tutorial

Eine **umfassende Anleitung** für DevOps, CI/CD und Kubernetes Deployment des Bank Portal Projekts.

---

## 📋 **Inhaltsverzeichnis**

1. [🎯 Überblick](#überblick)
2. [🐳 Docker & Container](#docker--container)
3. [☸️ Kubernetes Deployment](#kubernetes-deployment)
4. [🔄 CI/CD Pipeline](#cicd-pipeline)
5. [📊 Monitoring & Observability](#monitoring--observability)
6. [🔒 Security & Hardening](#security--hardening)
7. [💾 Backup & Recovery](#backup--recovery)
8. [🌐 Production Deployment](#production-deployment)
9. [🛠️ Troubleshooting](#troubleshooting)
10. [📚 Best Practices](#best-practices)

---

## 🎯 **Überblick**

### **Projekt-Architektur**
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Angular SPA   │────►│   Auth Service  │────►│ Account Service │
│   (Port 4200)   │     │   (Port 8081)   │     │   (Port 8082)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│     nginx       │     │   PostgreSQL    │     │   PostgreSQL    │
│  (Reverse Proxy)│     │   (Auth DB)     │     │ (Account DB)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### **Technologie-Stack**
- **Frontend:** Angular 18+, TypeScript, SCSS
- **Backend:** Spring Boot 3.x, Java 17, JWT
- **Database:** PostgreSQL 15
- **Container:** Docker, Docker Compose
- **Orchestration:** Kubernetes, Minikube
- **CI/CD:** GitHub Actions, Docker Hub
- **Monitoring:** Prometheus, Grafana
- **Security:** SSL/TLS, BCrypt, CORS

### **Deployment-Optionen**
1. **Development:** Docker Compose (empfohlen)
2. **Production:** Kubernetes + Helm
3. **Cloud:** AWS EKS, Azure AKS, GCP GKE

---

## 🐳 **Docker & Container**

### **1. Docker Images bauen**

#### **Auth Service**
```bash
cd auth-service
mvn clean package -DskipTests
docker build -t bankportal-demo-auth-service:latest .
```

#### **Account Service**
```bash
cd account-service
mvn clean package -DskipTests
docker build -t bankportal-demo-account-service:latest .
```

#### **Frontend**
```bash
cd frontend
npm ci
npm run build:prod
docker build -t bankportal-demo-frontend:latest .
```

### **2. Docker Compose Deployment**

#### **Development Setup**
```bash
# Alle Services starten
docker-compose up -d

# Status überprüfen
docker-compose ps

# Logs anzeigen
docker-compose logs -f

# Services stoppen
docker-compose down
```

#### **Production Setup**
```bash
# Production Images bauen
./scripts/deploy-prod.sh build

# Production Deployment
./scripts/deploy-prod.sh deploy

# Status überprüfen
./scripts/deploy-prod.sh status
```

### **3. Docker Best Practices**

#### **Multi-Stage Builds (Frontend)**
```dockerfile
# Build Stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build:prod

# Production Stage
FROM nginx:alpine
COPY --from=build /app/dist/bank-portal /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### **Security Optimierungen**
```dockerfile
# Non-root User
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup
USER appuser

# Health Checks
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8081/actuator/health || exit 1
```

---

## ☸️ **Kubernetes Deployment**

### **1. Minikube Setup**

#### **Installation & Start**
```bash
# Minikube installieren (macOS)
brew install minikube

# Minikube starten
minikube start --driver=docker --memory=4096 --cpus=2

# Dashboard aktivieren
minikube addons enable dashboard
minikube addons enable metrics-server

# Dashboard öffnen
minikube dashboard
```

#### **Docker Images zu Minikube laden**
```bash
# Images bauen und laden
eval $(minikube docker-env)
docker build -t bankportal-demo-auth-service:latest ./auth-service
docker build -t bankportal-demo-account-service:latest ./account-service
docker build -t bankportal-demo-frontend:latest ./frontend
```

### **2. Kubernetes Manifeste**

#### **Namespace erstellen**
```yaml
# k8s/dev/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: bankportal-dev
  labels:
    environment: development
    app: bankportal
```

#### **Secrets Management**
```yaml
# k8s/dev/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: bankportal-dev
type: Opaque
data:
  password: YWRtaW4=  # base64 encoded 'admin'
---
apiVersion: v1
kind: Secret
metadata:
  name: jwt-secret
  namespace: bankportal-dev
type: Opaque
data:
  secret: bXlzZWNyZXRrZXlteXNlY3JldGtleW15c2VjcmV0a2V5MTIzNDU2  # base64 encoded JWT secret
```

#### **PostgreSQL Deployment**
```yaml
# k8s/dev/postgres.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-auth
  namespace: bankportal-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-auth
  template:
    metadata:
      labels:
        app: postgres-auth
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_DB
          value: authdb
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-auth-pvc
```

### **3. Kubernetes Deployment**

#### **Alle Ressourcen deployen**
```bash
# Namespace erstellen
kubectl apply -f k8s/dev/namespace.yaml

# Secrets erstellen
kubectl apply -f k8s/dev/secrets.yaml

# PostgreSQL deployen
kubectl apply -f k8s/dev/postgres.yaml

# Services deployen
kubectl apply -f k8s/dev/deployment.yaml

# Ingress konfigurieren
kubectl apply -f k8s/dev/ingress.yaml
```

#### **Status überprüfen**
```bash
# Pods Status
kubectl get pods -n bankportal-dev

# Services Status
kubectl get services -n bankportal-dev

# Logs anzeigen
kubectl logs -f deployment/bankportal-auth-service -n bankportal-dev

# Pod beschreiben
kubectl describe pod <pod-name> -n bankportal-dev
```

### **4. Kubernetes Monitoring**

#### **Monitoring Script verwenden**
```bash
# Kontinuierliche Überwachung
./scripts/monitor-k8s.sh

# Watch Modus
./scripts/watch-k8s.sh
```

#### **Port-Forwarding für lokalen Zugriff**
```bash
# Frontend
kubectl port-forward service/bankportal-frontend-service 4200:80 -n bankportal-dev

# Auth Service
kubectl port-forward service/bankportal-auth-service 8081:8081 -n bankportal-dev

# Account Service
kubectl port-forward service/bankportal-account-service 8082:8082 -n bankportal-dev
```

---

## 🔄 **CI/CD Pipeline**

### **1. GitHub Actions Workflow**

#### **Basis Workflow (.github/workflows/ci.yml)**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: docker.io
  IMAGE_NAME: bankportal-demo

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    
    - name: Test Auth Service
      run: |
        cd auth-service
        mvn test
    
    - name: Test Account Service
      run: |
        cd account-service
        mvn test
    
    - name: Test Frontend
      run: |
        cd frontend
        npm ci
        npm test -- --watch=false --browsers=ChromeHeadless

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Auth Service
      uses: docker/build-push-action@v5
      with:
        context: ./auth-service
        push: true
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-auth:${{ github.sha }}
    
    - name: Build and push Account Service
      uses: docker/build-push-action@v5
      with:
        context: ./account-service
        push: true
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-account:${{ github.sha }}
    
    - name: Build and push Frontend
      uses: docker/build-push-action@v5
      with:
        context: ./frontend
        push: true
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-frontend:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v4
    
    - name: Deploy to Kubernetes
      run: |
        # Kubernetes Deployment Logic
        echo "Deploying to production..."
```

### **2. Lokale CI/CD Scripts**

#### **Schneller CI-Lauf**
```bash
#!/bin/bash
# scripts/ci-local-quick.sh

echo "🚀 Lokaler CI/CD Lauf"
echo "===================="

# Tests ausführen
echo "📋 Tests ausführen..."
cd auth-service && mvn test -q && cd ..
cd account-service && mvn test -q && cd ..
cd frontend && npm test -- --watch=false --browsers=ChromeHeadless && cd ..

# Images bauen
echo "🐳 Docker Images bauen..."
docker build -t bankportal-demo-auth-service:latest ./auth-service
docker build -t bankportal-demo-account-service:latest ./account-service
docker build -t bankportal-demo-frontend:latest ./frontend

# Deployment testen
echo "🚀 Deployment testen..."
docker-compose up -d
sleep 30

# Health Checks
echo "🏥 Health Checks..."
curl -f http://localhost:8081/actuator/health
curl -f http://localhost:8082/actuator/health
curl -f http://localhost:4200

echo "✅ CI/CD Lauf erfolgreich!"
```

---

*[Fortsetzung folgt in Teil 2...]*

### **3. Automatisierte Deployment Scripts**

#### **Lokales Deployment**
```bash
#!/bin/bash
# scripts/deploy-local.sh

set -e

echo "🏠 Lokales Deployment"
echo "===================="

# Environment prüfen
if [ ! -f ".env" ]; then
    echo "⚠️  .env Datei nicht gefunden, erstelle Standard-Konfiguration..."
    cp .env.example .env
fi

# Services stoppen
echo "🛑 Stoppe bestehende Services..."
docker-compose down --remove-orphans

# Images bauen
echo "🔨 Baue Docker Images..."
./scripts/deploy-prod.sh build

# Services starten
echo "🚀 Starte Services..."
docker-compose up -d

# Warten auf Services
echo "⏳ Warte auf Services..."
sleep 30

# Health Checks
echo "🏥 Führe Health Checks durch..."
./scripts/test-api.sh

echo "✅ Lokales Deployment erfolgreich!"
echo "Frontend: http://localhost:4200"
echo "Auth API: http://localhost:8081"
echo "Account API: http://localhost:8082"
```

---

## 📊 **Monitoring & Observability**

### **1. Prometheus Setup**

#### **Prometheus Konfiguration**
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'auth-service'
    static_configs:
      - targets: ['auth-service:8081']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 30s

  - job_name: 'account-service'
    static_configs:
      - targets: ['account-service:8082']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 30s

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

#### **Monitoring starten**
```bash
# Prometheus & Grafana starten
docker run -d --name prometheus -p 9090:9090 \
  -v $(pwd)/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest

docker run -d --name grafana -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest
```

### **2. Grafana Dashboards**

#### **Spring Boot Dashboard**
```json
{
  "dashboard": {
    "title": "Bank Portal - Spring Boot Metrics",
    "panels": [
      {
        "title": "HTTP Requests",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_server_requests_seconds_count[5m])",
            "legendFormat": "{{method}} {{uri}}"
          }
        ]
      },
      {
        "title": "JVM Memory",
        "type": "graph",
        "targets": [
          {
            "expr": "jvm_memory_used_bytes",
            "legendFormat": "{{area}}"
          }
        ]
      }
    ]
  }
}
```

### **3. Logging Strategy**

#### **Centralized Logging mit ELK Stack**
```yaml
# docker-compose.logging.yml
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.0
    volumes:
      - ./logging/logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5044:5044"

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
```

---

## 🔒 **Security & Hardening**

### **1. SSL/TLS Konfiguration**

#### **SSL Zertifikate generieren**
```bash
# Entwicklung (Self-Signed)
./scripts/generate-ssl.sh

# Produktion (Let's Encrypt)
certbot certonly --standalone -d yourdomain.com
```

#### **nginx SSL Konfiguration**
```nginx
# nginx/ssl.conf
server {
    listen 443 ssl http2;
    server_name localhost;

    ssl_certificate /etc/nginx/ssl/bankportal.crt;
    ssl_certificate_key /etc/nginx/ssl/bankportal.key;
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    # SSL Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;

    # Security Headers
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        proxy_pass http://frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### **2. Container Security**

#### **Security Scanning**
```bash
# Trivy Security Scanner
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image bankportal-demo-auth-service:latest

# Snyk Container Scanning
snyk container test bankportal-demo-auth-service:latest
```

#### **Dockerfile Security Best Practices**
```dockerfile
# Sicherer Dockerfile
FROM openjdk:17-jre-slim

# Non-root User erstellen
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Arbeitsverzeichnis
WORKDIR /app

# Nur notwendige Dateien kopieren
COPY --chown=appuser:appgroup target/app.jar app.jar

# User wechseln
USER appuser

# Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8081/actuator/health || exit 1

# Exponierte Ports
EXPOSE 8081

# Startup Command
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### **3. Kubernetes Security**

#### **Pod Security Standards**
```yaml
# k8s/security/pod-security.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    fsGroup: 1001
  containers:
  - name: app
    image: bankportal-demo-auth-service:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

#### **Network Policies**
```yaml
# k8s/security/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: bankportal-network-policy
  namespace: bankportal-dev
spec:
  podSelector:
    matchLabels:
      app: bankportal
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: bankportal
    ports:
    - protocol: TCP
      port: 8081
    - protocol: TCP
      port: 8082
```

---

## 💾 **Backup & Recovery**

### **1. Automatisierte Backups**

#### **Backup Script verwenden**
```bash
# Vollständiges Backup erstellen
./scripts/backup-system.sh backup

# Verfügbare Backups anzeigen
./scripts/backup-system.sh list

# Backup wiederherstellen
./scripts/backup-system.sh restore 20250704_191546

# Alte Backups bereinigen
./scripts/backup-system.sh cleanup
```

#### **Cron Job für automatische Backups**
```bash
# Crontab bearbeiten
crontab -e

# Tägliches Backup um 2:00 Uhr
0 2 * * * /path/to/bankportal-demo/scripts/backup-system.sh backup

# Wöchentliche Bereinigung am Sonntag
0 3 * * 0 /path/to/bankportal-demo/scripts/backup-system.sh cleanup
```

### **2. Disaster Recovery Plan**

#### **Recovery Procedure**
```bash
#!/bin/bash
# scripts/disaster-recovery.sh

echo "🚨 Disaster Recovery Procedure"
echo "=============================="

# 1. Neueste Backup finden
LATEST_BACKUP=$(ls -t backups/ | head -1)
echo "Neuestes Backup: $LATEST_BACKUP"

# 2. Services stoppen
echo "Stoppe alle Services..."
docker-compose down
kubectl delete namespace bankportal-dev --ignore-not-found

# 3. Volumes bereinigen
echo "Bereinige Volumes..."
docker volume prune -f

# 4. Backup wiederherstellen
echo "Stelle Backup wieder her..."
./scripts/backup-system.sh restore $LATEST_BACKUP

# 5. Services neu starten
echo "Starte Services neu..."
docker-compose up -d

# 6. Verifikation
echo "Verifiziere Services..."
sleep 60
./scripts/test-api.sh

echo "✅ Disaster Recovery abgeschlossen!"
```

### **3. Backup Verification**

#### **Backup Integrity Check**
```bash
#!/bin/bash
# scripts/verify-backup.sh

BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: $0 <backup-directory>"
    exit 1
fi

echo "🔍 Backup Verification"
echo "====================="

# SQL Dumps prüfen
echo "Prüfe SQL Dumps..."
if [ -f "$BACKUP_DIR/authdb_backup.sql" ]; then
    echo "✅ Auth DB Backup gefunden"
    # SQL Syntax prüfen
    psql --set ON_ERROR_STOP=1 -f "$BACKUP_DIR/authdb_backup.sql" --dry-run 2>/dev/null && echo "✅ Auth DB Syntax OK"
else
    echo "❌ Auth DB Backup fehlt"
fi

# Volume Backups prüfen
echo "Prüfe Volume Backups..."
for backup in "$BACKUP_DIR"/*.tar.gz; do
    if [ -f "$backup" ]; then
        echo "✅ $(basename "$backup")"
        # Tar Integrität prüfen
        tar -tzf "$backup" >/dev/null 2>&1 && echo "  ✅ Integrität OK" || echo "  ❌ Integrität FEHLER"
    fi
done

echo "Backup Verification abgeschlossen"
```

---

## 🌐 **Production Deployment**

### **1. Cloud Deployment (AWS)**

#### **EKS Cluster Setup**
```bash
# AWS CLI konfigurieren
aws configure

# EKS Cluster erstellen
eksctl create cluster \
  --name bankportal-prod \
  --version 1.28 \
  --region eu-central-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4

# kubectl konfigurieren
aws eks update-kubeconfig --region eu-central-1 --name bankportal-prod
```

#### **Helm Chart Deployment**
```bash
# Helm installieren
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Chart erstellen
helm create bankportal-chart

# Values für Production
cat > values-prod.yaml << EOF
replicaCount: 3
image:
  repository: your-registry/bankportal-demo
  tag: latest
service:
  type: LoadBalancer
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
  hosts:
    - host: bankportal.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
EOF

# Deployment
helm install bankportal ./bankportal-chart -f values-prod.yaml
```

### **2. Environment Management**

#### **Multi-Environment Setup**
```bash
# Development
kubectl apply -f k8s/dev/ --namespace=bankportal-dev

# Staging
kubectl apply -f k8s/staging/ --namespace=bankportal-staging

# Production
kubectl apply -f k8s/prod/ --namespace=bankportal-prod
```

#### **Configuration Management**
```yaml
# k8s/prod/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: bankportal-config
  namespace: bankportal-prod
data:
  SPRING_PROFILES_ACTIVE: "prod"
  LOGGING_LEVEL_ROOT: "WARN"
  MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE: "health,info,metrics"
  CORS_ALLOWED_ORIGINS: "https://bankportal.yourdomain.com"
```

---

## 🛠️ **Troubleshooting**

### **1. Häufige Probleme**

#### **Container startet nicht**
```bash
# Logs überprüfen
docker logs <container-name>

# Container interaktiv starten
docker run -it --entrypoint /bin/bash bankportal-demo-auth-service:latest

# Health Check manuell testen
curl -f http://localhost:8081/actuator/health
```

#### **Kubernetes Pod CrashLoopBackOff**
```bash
# Pod Logs anzeigen
kubectl logs -f <pod-name> -n bankportal-dev

# Pod Events anzeigen
kubectl describe pod <pod-name> -n bankportal-dev

# Pod Shell öffnen
kubectl exec -it <pod-name> -n bankportal-dev -- /bin/bash
```

#### **Datenbankverbindung fehlgeschlagen**
```bash
# Datenbankverbindung testen
kubectl exec -it postgres-auth-<pod-id> -n bankportal-dev -- psql -U admin -d authdb

# Service DNS auflösen
kubectl exec -it <pod-name> -n bankportal-dev -- nslookup postgres-auth-service
```

### **2. Debug Tools**

#### **Kubernetes Debug Utilities**
```bash
# K9s Terminal UI
brew install k9s
k9s -n bankportal-dev

# Stern für Log Streaming
brew install stern
stern bankportal -n bankportal-dev

# kubectx für Context Switching
brew install kubectx
kubectx minikube
kubens bankportal-dev
```

#### **Docker Debug Commands**
```bash
# Container Ressourcen anzeigen
docker stats

# Container Dateisystem untersuchen
docker exec -it <container> find / -name "*.log" 2>/dev/null

# Netzwerk Debugging
docker network ls
docker network inspect <network-name>
```

---

## 📚 **Best Practices**

### **1. Development Workflow**

#### **Git Workflow**
```bash
# Feature Branch erstellen
git checkout -b feature/new-feature

# Änderungen committen
git add .
git commit -m "feat: add new feature"

# Tests lokal ausführen
./scripts/ci-local-quick.sh

# Push und Pull Request
git push origin feature/new-feature
```

#### **Code Quality**
```bash
# Java Code Style (Checkstyle)
mvn checkstyle:check

# Frontend Linting
npm run lint

# Security Scanning
./scripts/security-scan.sh
```

### **2. Production Readiness Checklist**

#### **✅ Security**
- [ ] SSL/TLS Zertifikate konfiguriert
- [ ] Secrets extern verwaltet
- [ ] Container Security Scanning
- [ ] Network Policies implementiert
- [ ] RBAC konfiguriert

#### **✅ Monitoring**
- [ ] Prometheus Metriken aktiviert
- [ ] Grafana Dashboards konfiguriert
- [ ] Alerting Rules definiert
- [ ] Log Aggregation eingerichtet

#### **✅ Backup & Recovery**
- [ ] Automatisierte Backups konfiguriert
- [ ] Backup Verification implementiert
- [ ] Disaster Recovery Plan getestet
- [ ] RTO/RPO Ziele definiert

#### **✅ Performance**
- [ ] Resource Limits gesetzt
- [ ] Horizontal Pod Autoscaling konfiguriert
- [ ] Load Testing durchgeführt
- [ ] Database Performance optimiert

### **3. Maintenance & Updates**

#### **Regelmäßige Wartung**
```bash
# Wöchentliche Wartung
./scripts/weekly-maintenance.sh

# Security Updates
./scripts/security-updates.sh

# Performance Monitoring
./scripts/performance-check.sh
```

---

## 🎯 **Zusammenfassung**

### **Deployment-Optionen im Überblick**

| Umgebung | Technologie | Verwendung | Komplexität |
|----------|-------------|------------|-------------|
| **Development** | Docker Compose | Lokale Entwicklung | ⭐ Niedrig |
| **Staging** | Kubernetes (Minikube) | Testing & Integration | ⭐⭐ Mittel |
| **Production** | Kubernetes (Cloud) | Live System | ⭐⭐⭐ Hoch |

### **Nützliche Commands**

```bash
# Schneller Start
docker-compose up -d

# Kubernetes Deployment
kubectl apply -f k8s/dev/

# Monitoring starten
docker run -d -p 9090:9090 prom/prometheus
docker run -d -p 3000:3000 grafana/grafana

# Backup erstellen
./scripts/backup-system.sh backup

# CI/CD lokal testen
./scripts/ci-local-quick.sh
```

### **URLs nach Deployment**

- **Frontend:** http://localhost:4200
- **Auth API:** http://localhost:8081
- **Account API:** http://localhost:8082
- **Prometheus:** http://localhost:9090
- **Grafana:** http://localhost:3000

---

**🎉 Ihr Bank Portal ist jetzt vollständig DevOps-ready!**

Dieses Tutorial deckt alle Aspekte von der lokalen Entwicklung bis zum Production Deployment ab. Für spezifische Fragen oder erweiterte Konfigurationen, konsultieren Sie die jeweiligen Abschnitte oder die Dokumentation der verwendeten Tools.
