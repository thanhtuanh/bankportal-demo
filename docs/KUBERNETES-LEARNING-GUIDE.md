# 🚀 Kubernetes Learning Guide - Bank Portal Demo

## 📋 **Übersicht**

Dieser Guide führt Sie durch das Lernen von Kubernetes mit dem Bank Portal Projekt. Sie lernen alle wichtigen K8s Konzepte hands-on mit einem realen Microservices-Projekt.

---

## 🎯 **Quick Start**

### **Ein-Klick Kubernetes Demo:**
```bash
# Vollständiges K8s Setup starten
./scripts/start-k8s-demo.sh

# Minimales Setup (ohne Monitoring)
./scripts/start-k8s-demo.sh --minimal

# Demo stoppen
./scripts/stop-k8s-demo.sh
```

### **Was wird deployed:**
- **2x PostgreSQL** Databases (Auth + Account)
- **2x Spring Boot** Services (Auth + Account) 
- **1x Angular** Frontend
- **1x Prometheus** (Monitoring)
- **1x Grafana** (Dashboards)
- **1x Kubernetes Dashboard** (Cluster Management)

**Gesamt: 8-10 Container** in Kubernetes Pods

---

## 🏗️ **Kubernetes Architektur**

### **Namespace-basierte Isolation:**
```
bankportal (Namespace)
├── postgres-auth (Deployment + Service)
├── postgres-account (Deployment + Service)
├── auth-service (Deployment + Service + 2 Replicas)
├── account-service (Deployment + Service + 2 Replicas)
├── frontend (Deployment + Service + 2 Replicas)
├── prometheus (Deployment + Service)
└── grafana (Deployment + Service)
```

### **Service Discovery:**
```
auth-service:8081 ←→ postgres-auth-service:5432
account-service:8082 ←→ postgres-account-service:5432
frontend:80 ←→ auth-service:8081 + account-service:8082
```

---

## 📚 **Lernpfad (4 Wochen)**

### **Woche 1: Kubernetes Grundlagen**

#### **Tag 1-2: Setup & Erste Schritte**
```bash
# 1. Minikube installieren und starten
minikube start --cpus=4 --memory=8192

# 2. kubectl Grundbefehle lernen
kubectl version
kubectl cluster-info
kubectl get nodes

# 3. Erstes Demo starten
./scripts/start-k8s-demo.sh --minimal
```

#### **Tag 3-4: Pods & Deployments verstehen**
```bash
# Pods anzeigen
kubectl get pods -n bankportal

# Pod Details anzeigen
kubectl describe pod <pod-name> -n bankportal

# In Pod einloggen
kubectl exec -it <pod-name> -n bankportal -- /bin/bash

# Pod Logs anzeigen
kubectl logs -f <pod-name> -n bankportal
```

#### **Tag 5-7: Services & Networking**
```bash
# Services anzeigen
kubectl get services -n bankportal

# Service Details
kubectl describe service auth-service -n bankportal

# Endpoints prüfen
kubectl get endpoints -n bankportal

# Port Forwarding testen
kubectl port-forward service/auth-service 8081:8081 -n bankportal
```

### **Woche 2: Konfiguration & Secrets**

#### **Tag 8-10: ConfigMaps**
```bash
# ConfigMaps anzeigen
kubectl get configmaps -n bankportal

# ConfigMap Inhalt anzeigen
kubectl describe configmap app-config -n bankportal

# ConfigMap bearbeiten
kubectl edit configmap app-config -n bankportal
```

#### **Tag 11-12: Secrets Management**
```bash
# Secrets anzeigen (ohne Werte)
kubectl get secrets -n bankportal

# Secret Details
kubectl describe secret app-secrets -n bankportal

# Secret Werte dekodieren (nur für Lernen!)
kubectl get secret app-secrets -n bankportal -o yaml
echo "cGFzc3dvcmQxMjM=" | base64 -d
```

#### **Tag 13-14: Environment Variables**
```bash
# Umgebungsvariablen in Pod prüfen
kubectl exec -it <auth-service-pod> -n bankportal -- env | grep POSTGRES

# ConfigMap/Secret Verwendung in Deployment
kubectl get deployment auth-service -n bankportal -o yaml
```

### **Woche 3: Skalierung & Updates**

#### **Tag 15-17: Scaling**
```bash
# Aktuelle Replicas anzeigen
kubectl get deployments -n bankportal

# Skalierung
kubectl scale deployment auth-service --replicas=3 -n bankportal

# Autoscaling (erweitert)
kubectl autoscale deployment auth-service --cpu-percent=50 --min=2 --max=10 -n bankportal
```

#### **Tag 18-19: Rolling Updates**
```bash
# Update Image
kubectl set image deployment/auth-service auth-service=bankportal/auth-service:v2 -n bankportal

# Rollout Status
kubectl rollout status deployment/auth-service -n bankportal

# Rollback
kubectl rollout undo deployment/auth-service -n bankportal
```

#### **Tag 20-21: Health Checks**
```bash
# Liveness/Readiness Probes verstehen
kubectl describe deployment auth-service -n bankportal

# Health Check URLs testen
kubectl port-forward service/auth-service 8081:8081 -n bankportal
curl http://localhost:8081/api/health
```

### **Woche 4: Monitoring & Troubleshooting**

#### **Tag 22-24: Monitoring Setup**
```bash
# Vollständiges Monitoring starten
./scripts/start-k8s-demo.sh

# Prometheus Targets prüfen
kubectl port-forward service/prometheus 9090:9090 -n bankportal
# → http://localhost:9090/targets

# Grafana Dashboards
kubectl port-forward service/grafana 3000:3000 -n bankportal
# → http://localhost:3000 (admin/admin123)
```

#### **Tag 25-26: Troubleshooting**
```bash
# Pod Probleme diagnostizieren
kubectl get pods -n bankportal
kubectl describe pod <failing-pod> -n bankportal
kubectl logs <failing-pod> -n bankportal

# Events anzeigen
kubectl get events -n bankportal --sort-by=.metadata.creationTimestamp

# Resource Usage
kubectl top pods -n bankportal
kubectl top nodes
```

#### **Tag 27-28: Kubernetes Dashboard**
```bash
# Dashboard Token generieren
kubectl -n kubernetes-dashboard create token admin-user

# Proxy starten
kubectl proxy

# Dashboard öffnen
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

---

## 🛠️ **Praktische Übungen**

### **Übung 1: Pod Lifecycle verstehen**
```bash
# 1. Pod erstellen
kubectl run test-pod --image=nginx -n bankportal

# 2. Pod Status verfolgen
kubectl get pods -n bankportal -w

# 3. Pod löschen
kubectl delete pod test-pod -n bankportal
```

### **Übung 2: Service Discovery testen**
```bash
# 1. In Auth Service Pod einloggen
kubectl exec -it <auth-service-pod> -n bankportal -- /bin/bash

# 2. Andere Services erreichen
curl http://postgres-auth-service:5432
curl http://account-service:8082/api/health

# 3. DNS Resolution testen
nslookup postgres-auth-service
```

### **Übung 3: ConfigMap Live-Update**
```bash
# 1. ConfigMap ändern
kubectl edit configmap app-config -n bankportal

# 2. Pod neu starten (um Änderungen zu laden)
kubectl rollout restart deployment/auth-service -n bankportal

# 3. Änderungen verifizieren
kubectl exec -it <new-pod> -n bankportal -- env | grep LOG_LEVEL
```

### **Übung 4: Skalierung unter Last**
```bash
# 1. Load Testing Setup
kubectl run load-test --image=busybox -n bankportal -- /bin/sh -c "while true; do wget -q -O- http://auth-service:8081/api/health; sleep 1; done"

# 2. Skalierung beobachten
kubectl scale deployment auth-service --replicas=5 -n bankportal
kubectl get pods -n bankportal -w

# 3. Load Test stoppen
kubectl delete pod load-test -n bankportal
```

---

## 🔍 **Debugging Cheat Sheet**

### **Pod Probleme:**
```bash
# Pod Status
kubectl get pods -n bankportal
kubectl describe pod <pod-name> -n bankportal

# Häufige Status:
# - Pending: Scheduling-Problem
# - CrashLoopBackOff: Application startet nicht
# - ImagePullBackOff: Image nicht verfügbar
# - Running: Alles OK
```

### **Service Probleme:**
```bash
# Service Endpoints prüfen
kubectl get endpoints -n bankportal

# Service ohne Endpoints:
# → Selector stimmt nicht mit Pod Labels überein
kubectl get pods --show-labels -n bankportal
kubectl describe service <service-name> -n bankportal
```

### **Networking Probleme:**
```bash
# DNS Resolution testen
kubectl run dns-test --image=busybox -n bankportal -- nslookup auth-service

# Port Connectivity testen
kubectl run net-test --image=busybox -n bankportal -- nc -zv auth-service 8081
```

---

## 📊 **Monitoring & Observability**

### **Prometheus Queries (Lernen):**
```promql
# Service Health
up{job="auth-service"}

# HTTP Request Rate
rate(http_requests_total[5m])

# JVM Memory Usage
jvm_memory_used_bytes{area="heap"}

# Pod CPU Usage
rate(container_cpu_usage_seconds_total[5m])
```

### **Grafana Dashboards:**
1. **Kubernetes Cluster Monitoring** (ID: 6417)
2. **Spring Boot Statistics** (ID: 8588)
3. **JVM Micrometer** (ID: 4701)

### **Custom Metrics:**
```bash
# Application Metrics
curl http://localhost:8081/actuator/prometheus

# Kubernetes Metrics
kubectl top pods -n bankportal
kubectl top nodes
```

---

## 🎓 **Erweiterte Konzepte**

### **Ingress Controller (Optional):**
```bash
# Minikube Ingress aktivieren
minikube addons enable ingress

# Ingress Resource erstellen
kubectl apply -f - << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bankportal-ingress
  namespace: bankportal
spec:
  rules:
  - host: bankportal.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
EOF

# /etc/hosts bearbeiten
echo "$(minikube ip) bankportal.local" | sudo tee -a /etc/hosts
```

### **Persistent Volumes (Optional):**
```bash
# PV und PVC für PostgreSQL
kubectl apply -f - << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/postgres
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: bankportal
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

---

## 🎯 **Lernziele Checkliste**

### **Woche 1:**
- [ ] Kubernetes Cluster Setup verstanden
- [ ] kubectl Grundbefehle beherrscht
- [ ] Pods erstellen, anzeigen, löschen
- [ ] Services und Port Forwarding verstanden

### **Woche 2:**
- [ ] ConfigMaps erstellen und verwenden
- [ ] Secrets sicher verwalten
- [ ] Environment Variables in Pods
- [ ] Service Discovery funktioniert

### **Woche 3:**
- [ ] Deployments skalieren
- [ ] Rolling Updates durchführen
- [ ] Health Checks konfigurieren
- [ ] Troubleshooting Grundlagen

### **Woche 4:**
- [ ] Monitoring mit Prometheus/Grafana
- [ ] Kubernetes Dashboard verwenden
- [ ] Erweiterte Debugging-Techniken
- [ ] Production-Ready Konzepte

---

## 🚀 **Nächste Schritte**

### **Nach dem Grundkurs:**
1. **Helm Charts** - Package Management
2. **Operators** - Custom Resources
3. **Service Mesh** - Istio/Linkerd
4. **GitOps** - ArgoCD/Flux
5. **Cloud Kubernetes** - EKS/GKE/AKS

### **Zertifizierungen:**
- **CKAD** - Certified Kubernetes Application Developer
- **CKA** - Certified Kubernetes Administrator
- **CKS** - Certified Kubernetes Security Specialist

---

## 🎉 **Erfolg messen**

### **Nach 4 Wochen können Sie:**
- ✅ Kubernetes Cluster verwalten
- ✅ Microservices in K8s deployen
- ✅ Services skalieren und updaten
- ✅ Probleme diagnostizieren und lösen
- ✅ Monitoring und Dashboards einrichten
- ✅ Production-Ready Deployments erstellen

**🚀 Mit diesem strukturierten Lernpfad beherrschen Sie Kubernetes hands-on mit einem realen Banking-Projekt!**
