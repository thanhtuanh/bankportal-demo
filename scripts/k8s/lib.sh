#!/usr/bin/env bash

# Zentrale K8s-Hilfsbibliothek für die Demo-Teilschritte
# Ziel: Sub‑Skripte in scripts/k8s/ sind kurz, nachvollziehbar und
# entkoppelt von den langen Demo-Skripten.

set -Eeuo pipefail

# Farben (nur setzen, wenn nicht bereits vorhanden)
: "${RED:=\033[0;31m}"
: "${GREEN:=\033[0;32m}"
: "${YELLOW:=\033[1;33m}"
: "${BLUE:=\033[0;34m}"
: "${PURPLE:=\033[0;35m}"
: "${CYAN:=\033[0;36m}"
: "${NC:=\033[0m}"

# Basis-Defaults (können über Env überschrieben werden)
export NAMESPACE="${NAMESPACE:-bankportal}"
export K8S_DIR="${K8S_DIR:-temp-k8s-files}"
export MONITORING_ENABLED="${MONITORING_ENABLED:-true}"
export DASHBOARD_ENABLED="${DASHBOARD_ENABLED:-true}"

# =============================
# Funktionen (aus Demo extrahiert)
# =============================

check_prerequisites() {
  echo -e "${YELLOW}🔍 Prüfe Voraussetzungen...${NC}"
  if ! command -v kubectl >/dev/null 2>&1; then
    echo -e "${RED}❌ kubectl ist nicht installiert${NC}"; exit 1
  fi
  if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}❌ Kein Kubernetes-Cluster verfügbar${NC}"; exit 1
  fi
  if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker ist nicht installiert${NC}"; exit 1
  fi
  echo -e "${GREEN}✅ Voraussetzungen ok${NC}"
}

build_images() {
  echo -e "${BLUE}🔨 Baue Docker Images...${NC}"
  echo -e "${CYAN}   📦 Auth Service...${NC}"; docker build -t bankportal/auth-service:latest ./auth-service >/dev/null 2>&1
  echo -e "${CYAN}   📦 Account Service...${NC}"; docker build -t bankportal/account-service:latest ./account-service >/dev/null 2>&1
  echo -e "${CYAN}   📦 Frontend...${NC}"; docker build -t bankportal/frontend:latest ./frontend >/dev/null 2>&1
  echo -e "${GREEN}✅ Images gebaut${NC}"
}

load_images_to_cluster() {
  echo -e "${BLUE}📤 Lade Images in den Cluster...${NC}"
  local ctx; ctx=$(kubectl config current-context || true)
  if echo "$ctx" | grep -q minikube; then
    minikube image load bankportal/auth-service:latest
    minikube image load bankportal/account-service:latest
    minikube image load bankportal/frontend:latest
  elif echo "$ctx" | grep -q kind; then
    local name; name="${ctx#kind-}"
    kind load docker-image bankportal/auth-service:latest --name "$name"
    kind load docker-image bankportal/account-service:latest --name "$name"
    kind load docker-image bankportal/frontend:latest --name "$name"
  else
    echo -e "${YELLOW}ℹ️  Docker Desktop / anderer Cluster – Images lokal verfügbar${NC}"
  fi
  echo -e "${GREEN}✅ Images bereit${NC}"
}

create_k8s_manifests() {
  echo -e "${BLUE}📝 Erstelle Basis-Manifeste...${NC}"
  mkdir -p "$K8S_DIR/base" "$K8S_DIR/monitoring"
  cat > "$K8S_DIR/base/namespace.yaml" <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
  labels:
    name: ${NAMESPACE}
EOF
  cat > "$K8S_DIR/base/configmap.yaml" <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: ${NAMESPACE}
data:
  SPRING_PROFILES_ACTIVE: "kubernetes"
  LOG_LEVEL: "INFO"
  POSTGRES_AUTH_HOST: "postgres-auth-service"
  POSTGRES_AUTH_PORT: "5432"
  POSTGRES_AUTH_DB: "authdb"
  POSTGRES_ACCOUNT_HOST: "postgres-account-service"
  POSTGRES_ACCOUNT_PORT: "5432"
  POSTGRES_ACCOUNT_DB: "accountdb"
  AUTH_SERVICE_URL: "http://auth-service:8081"
  ACCOUNT_SERVICE_URL: "http://account-service:8082"
  JWT_EXPIRATION: "3600"
EOF
  cat > "$K8S_DIR/base/secrets.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: ${NAMESPACE}
type: Opaque
data:
  POSTGRES_AUTH_PASSWORD: cGFzc3dvcmQxMjM=
  POSTGRES_ACCOUNT_PASSWORD: cGFzc3dvcmQxMjM=
  JWT_SECRET: bXlzZWNyZXRrZXlteXNlY3JldGtleW15c2VjcmV0a2V5MTIzNDU2
EOF
}

create_database_manifests() {
  echo -e "${CYAN}   📄 Erstelle DB-Manifeste...${NC}"
  cat > "$K8S_DIR/base/postgres-auth.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-auth
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels: {app: postgres-auth}
  template:
    metadata: {labels: {app: postgres-auth}}
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports: [{containerPort: 5432}]
        env:
        - name: POSTGRES_DB
          valueFrom: {configMapKeyRef: {name: app-config, key: POSTGRES_AUTH_DB}}
        - {name: POSTGRES_USER, value: "admin"}
        - name: POSTGRES_PASSWORD
          valueFrom: {secretKeyRef: {name: app-secrets, key: POSTGRES_AUTH_PASSWORD}}
---
apiVersion: v1
kind: Service
metadata: {name: postgres-auth-service, namespace: ${NAMESPACE}}
spec:
  selector: {app: postgres-auth}
  ports: [{port: 5432, targetPort: 5432}]
EOF

  cat > "$K8S_DIR/base/postgres-account.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-account
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels: {app: postgres-account}
  template:
    metadata: {labels: {app: postgres-account}}
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports: [{containerPort: 5432}]
        env:
        - name: POSTGRES_DB
          valueFrom: {configMapKeyRef: {name: app-config, key: POSTGRES_ACCOUNT_DB}}
        - {name: POSTGRES_USER, value: "admin"}
        - name: POSTGRES_PASSWORD
          valueFrom: {secretKeyRef: {name: app-secrets, key: POSTGRES_ACCOUNT_PASSWORD}}
---
apiVersion: v1
kind: Service
metadata: {name: postgres-account-service, namespace: ${NAMESPACE}}
spec:
  selector: {app: postgres-account}
  ports: [{port: 5432, targetPort: 5432}]
EOF
}

create_service_manifests() {
  echo -e "${CYAN}   📄 Erstelle Service-Manifeste...${NC}"
  cat > "$K8S_DIR/base/auth-service.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: auth-service, namespace: ${NAMESPACE}}
spec:
  replicas: 2
  selector: {matchLabels: {app: auth-service}}
  template:
    metadata: {labels: {app: auth-service}}
    spec:
      containers:
      - name: auth-service
        image: bankportal/auth-service:latest
        imagePullPolicy: Never
        ports: [{containerPort: 8081}]
        env:
        - name: SPRING_PROFILES_ACTIVE
          valueFrom: {configMapKeyRef: {name: app-config, key: SPRING_PROFILES_ACTIVE}}
        - name: POSTGRES_AUTH_HOST
          valueFrom: {configMapKeyRef: {name: app-config, key: POSTGRES_AUTH_HOST}}
        - name: POSTGRES_AUTH_PASSWORD
          valueFrom: {secretKeyRef: {name: app-secrets, key: POSTGRES_AUTH_PASSWORD}}
        - name: JWT_SECRET
          valueFrom: {secretKeyRef: {name: app-secrets, key: JWT_SECRET}}
---
apiVersion: v1
kind: Service
metadata: {name: auth-service, namespace: ${NAMESPACE}}
spec:
  selector: {app: auth-service}
  ports: [{port: 8081, targetPort: 8081}]
  type: ClusterIP
EOF

  cat > "$K8S_DIR/base/account-service.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: account-service, namespace: ${NAMESPACE}}
spec:
  replicas: 2
  selector: {matchLabels: {app: account-service}}
  template:
    metadata: {labels: {app: account-service}}
    spec:
      containers:
      - name: account-service
        image: bankportal/account-service:latest
        imagePullPolicy: Never
        ports: [{containerPort: 8082}]
        env:
        - name: SPRING_PROFILES_ACTIVE
          valueFrom: {configMapKeyRef: {name: app-config, key: SPRING_PROFILES_ACTIVE}}
        - name: POSTGRES_ACCOUNT_HOST
          valueFrom: {configMapKeyRef: {name: app-config, key: POSTGRES_ACCOUNT_HOST}}
        - name: POSTGRES_ACCOUNT_PASSWORD
          valueFrom: {secretKeyRef: {name: app-secrets, key: POSTGRES_ACCOUNT_PASSWORD}}
        - name: AUTH_SERVICE_URL
          valueFrom: {configMapKeyRef: {name: app-config, key: AUTH_SERVICE_URL}}
---
apiVersion: v1
kind: Service
metadata: {name: account-service, namespace: ${NAMESPACE}}
spec:
  selector: {app: account-service}
  ports: [{port: 8082, targetPort: 8082}]
  type: ClusterIP
EOF

  cat > "$K8S_DIR/base/frontend.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: frontend, namespace: ${NAMESPACE}}
spec:
  replicas: 2
  selector: {matchLabels: {app: frontend}}
  template:
    metadata: {labels: {app: frontend}}
    spec:
      containers:
      - name: frontend
        image: bankportal/frontend:latest
        imagePullPolicy: Never
        ports: [{containerPort: 80}]
        env:
        - name: AUTH_SERVICE_URL
          valueFrom: {configMapKeyRef: {name: app-config, key: AUTH_SERVICE_URL}}
        - name: ACCOUNT_SERVICE_URL
          valueFrom: {configMapKeyRef: {name: app-config, key: ACCOUNT_SERVICE_URL}}
---
apiVersion: v1
kind: Service
metadata: {name: frontend, namespace: ${NAMESPACE}}
spec:
  selector: {app: frontend}
  ports: [{port: 80, targetPort: 80}]
  type: NodePort
EOF
}

create_monitoring_manifests() {
  if [[ "$MONITORING_ENABLED" != "true" ]]; then return 0; fi
  echo -e "${CYAN}   📊 Erstelle Monitoring-Manifeste...${NC}"
  cat > "$K8S_DIR/monitoring/prometheus.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: prometheus, namespace: ${NAMESPACE}}
spec:
  replicas: 1
  selector: {matchLabels: {app: prometheus}}
  template:
    metadata: {labels: {app: prometheus}}
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports: [{containerPort: 9090}]
---
apiVersion: v1
kind: Service
metadata: {name: prometheus, namespace: ${NAMESPACE}}
spec:
  selector: {app: prometheus}
  ports: [{port: 9090, targetPort: 9090}]
EOF
  cat > "$K8S_DIR/monitoring/grafana.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: grafana, namespace: ${NAMESPACE}}
spec:
  replicas: 1
  selector: {matchLabels: {app: grafana}}
  template:
    metadata: {labels: {app: grafana}}
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports: [{containerPort: 3000}]
        env:
        - {name: GF_SECURITY_ADMIN_PASSWORD, value: "admin123"}
---
apiVersion: v1
kind: Service
metadata: {name: grafana, namespace: ${NAMESPACE}}
spec:
  selector: {app: grafana}
  ports: [{port: 3000, targetPort: 3000}]
EOF
}

deploy_to_kubernetes() {
  echo -e "${BLUE}🚀 Deploye zu Kubernetes...${NC}"
  kubectl apply -f "$K8S_DIR/base/namespace.yaml"
  kubectl apply -f "$K8S_DIR/base/configmap.yaml"
  kubectl apply -f "$K8S_DIR/base/secrets.yaml"
  kubectl apply -f "$K8S_DIR/base/postgres-auth.yaml"
  kubectl apply -f "$K8S_DIR/base/postgres-account.yaml"
  kubectl apply -f "$K8S_DIR/base/auth-service.yaml"
  kubectl apply -f "$K8S_DIR/base/account-service.yaml"
  kubectl apply -f "$K8S_DIR/base/frontend.yaml"
  if [[ "$MONITORING_ENABLED" == "true" ]]; then
    kubectl apply -f "$K8S_DIR/monitoring/"
  fi
}

wait_for_services() {
  echo -e "${YELLOW}⏳ Warte auf Deployments...${NC}"
  kubectl wait --for=condition=available deployment/auth-service -n "$NAMESPACE" --timeout=300s || true
  kubectl wait --for=condition=available deployment/account-service -n "$NAMESPACE" --timeout=300s || true
  kubectl wait --for=condition=available deployment/frontend -n "$NAMESPACE" --timeout=300s || true
}

show_status() {
  echo -e "${PURPLE}📊 Ressourcen im Namespace ${NAMESPACE}:${NC}"
  kubectl get all -n "$NAMESPACE" || true
}

setup_port_forwarding() {
  echo -e "${BLUE}🔗 Starte Port-Forwarding...${NC}"
  pkill -f "kubectl port-forward" 2>/dev/null || true
  sleep 1
  kubectl port-forward service/frontend 4200:80 -n "$NAMESPACE" >/dev/null 2>&1 &
  kubectl port-forward service/auth-service 8081:8081 -n "$NAMESPACE" >/dev/null 2>&1 &
  kubectl port-forward service/account-service 8082:8082 -n "$NAMESPACE" >/dev/null 2>&1 &
  if [[ "$MONITORING_ENABLED" == "true" ]]; then
    kubectl port-forward service/prometheus 9090:9090 -n "$NAMESPACE" >/dev/null 2>&1 &
    kubectl port-forward service/grafana 3000:3000 -n "$NAMESPACE" >/dev/null 2>&1 &
  fi
}

  install_k8s_dashboard() {
    [[ "$DASHBOARD_ENABLED" == "true" ]] || return 0
    echo -e "${BLUE}📊 Installiere Kubernetes Dashboard...${NC}"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml >/dev/null 2>&1 || true
    cat <<EOF | kubectl apply -f - >/dev/null 2>&1 || true
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
}

show_access_info() {
  echo -e "${GREEN}🎉 ======================================"
  echo "   BANK PORTAL KUBERNETES DEMO BEREIT!"
  echo "======================================${NC}"
  echo ""
  echo -e "${PURPLE}🌐 Service URLs (Port Forwarding):${NC}"
  echo -e "${CYAN}   Frontend:        http://localhost:4200${NC}"
  echo -e "${CYAN}   Auth Service:    http://localhost:8081${NC}"
  echo -e "${CYAN}   Account Service: http://localhost:8082${NC}"
  if [[ "$MONITORING_ENABLED" == "true" ]]; then
    echo ""
    echo -e "${PURPLE}📊 Monitoring URLs:${NC}"
    echo -e "${CYAN}   Prometheus:      http://localhost:9090${NC}"
    echo -e "${CYAN}   Grafana:         http://localhost:3000 (admin/admin123)${NC}"
  fi
  if [[ "$DASHBOARD_ENABLED" == "true" ]]; then
    echo ""
    echo -e "${PURPLE}📊 Kubernetes Dashboard:${NC}"
    echo -e "${CYAN}   1. Starte Proxy: kubectl proxy${NC}"
    echo -e "${CYAN}   2. URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/${NC}"
    echo -e "${CYAN}   3. Token: kubectl -n kubernetes-dashboard create token admin-user${NC}"
  fi
  echo ""
  echo -e "${PURPLE}🛠️ Nützliche Befehle:${NC}"
  echo -e "${CYAN}   Pods anzeigen:     kubectl get pods -n $NAMESPACE${NC}"
  echo -e "${CYAN}   Services anzeigen: kubectl get services -n $NAMESPACE${NC}"
  echo -e "${CYAN}   Logs anzeigen:     kubectl logs -f deployment/auth-service -n $NAMESPACE${NC}"
  echo -e "${CYAN}   Demo stoppen:      ./scripts/stop-k8s.sh${NC}"
}

stop_port_forwarding() {
  echo -e "${YELLOW}🔗 Stoppe Port-Forwarding...${NC}"
  pkill -f "kubectl port-forward" 2>/dev/null || true
}

delete_k8s_resources() {
  echo -e "${YELLOW}🗑️  Lösche Ressourcen...${NC}"
  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    kubectl delete -f "$K8S_DIR/monitoring" -n "$NAMESPACE" --ignore-not-found=true >/dev/null 2>&1 || true
    kubectl delete -f "$K8S_DIR/base/frontend.yaml" --ignore-not-found=true >/dev/null 2>&1 || true
    kubectl delete -f "$K8S_DIR/base/account-service.yaml" --ignore-not-found=true >/dev/null 2>&1 || true
    kubectl delete -f "$K8S_DIR/base/auth-service.yaml" --ignore-not-found=true >/dev/null 2>&1 || true
    kubectl delete -f "$K8S_DIR/base/postgres-account.yaml" --ignore-not-found=true >/dev/null 2>&1 || true
    kubectl delete -f "$K8S_DIR/base/postgres-auth.yaml" --ignore-not-found=true >/dev/null 2>&1 || true
    kubectl delete -f "$K8S_DIR/base/secrets.yaml" --ignore-not-found=true >/dev/null 2>&1 || true
    kubectl delete -f "$K8S_DIR/base/configmap.yaml" --ignore-not-found=true >/dev/null 2>&1 || true
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true >/dev/null 2>&1 || true
  fi
}

delete_k8s_dashboard() {
  echo -e "${YELLOW}📊 Entferne Dashboard...${NC}"
  kubectl delete clusterrolebinding admin-user --ignore-not-found=true >/dev/null 2>&1 || true
  kubectl delete serviceaccount admin-user -n kubernetes-dashboard --ignore-not-found=true >/dev/null 2>&1 || true
  kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml --ignore-not-found=true >/dev/null 2>&1 || true
}

cleanup_generated_files() {
  echo -e "${YELLOW}🧹 Bereinige generierte Dateien...${NC}"
  rm -rf "$K8S_DIR" || true
}

show_final_status() {
  echo -e "${BLUE}📊 Finale Statusprüfung...${NC}"
  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Namespace $NAMESPACE existiert noch${NC}"
  else
    echo -e "${GREEN}✅ Namespace entfernt${NC}"
  fi
}
