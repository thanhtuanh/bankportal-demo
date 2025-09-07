#!/usr/bin/env bash
# 04-generate-manifests.sh — Kubernetes-Manifeste generieren
# Zweck: Erstellt YAML-Dateien für Namespace, ConfigMap, Secrets, Datenbanken, Services und Monitoring
# Hinweis: Stellt sicher, dass alle benötigten Verzeichnisse und Umgebungsvariablen definiert sind

. "$(dirname "$0")/../common.sh"
banner "📝 Kubernetes-Manifeste generieren"

# Sicherstellen, dass K8S_DIR definiert ist
: "${K8S_DIR:=temp-k8s-files}"

# Verzeichnisse für Manifeste erstellen
BASE_OUT="${K8S_DIR}/base"
MON_OUT="${K8S_DIR}/monitoring"
mkdir -p "${BASE_OUT}" "${MON_OUT}"

# Namespace erstellen
cat > "${BASE_OUT}/namespace.yaml" <<EOT
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
  labels: { name: ${NAMESPACE} }
EOT

# ConfigMap erstellen
cat > "${BASE_OUT}/configmap.yaml" <<EOT
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
EOT

# Secrets erstellen
cat > "${BASE_OUT}/secrets.yaml" <<EOT
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
EOT

# Postgres Auth-Datenbank
cat > "${BASE_OUT}/postgres-auth.yaml" <<EOT
apiVersion: apps/v1
kind: Deployment
metadata: { name: postgres-auth, namespace: ${NAMESPACE} }
spec:
  replicas: 1
  selector: { matchLabels: { app: postgres-auth } }
  template:
    metadata: { labels: { app: postgres-auth } }
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports: [{ containerPort: 5432 }]
        env:
        - name: POSTGRES_DB
          valueFrom: { configMapKeyRef: { name: app-config, key: POSTGRES_AUTH_DB } }
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          valueFrom: { secretKeyRef: { name: app-secrets, key: POSTGRES_AUTH_PASSWORD } }
        volumeMounts: [{ name: postgres-auth-storage, mountPath: /var/lib/postgresql/data }]
      volumes: [{ name: postgres-auth-storage, emptyDir: {} }]
---
apiVersion: v1
kind: Service
metadata: { name: postgres-auth-service, namespace: ${NAMESPACE} }
spec:
  selector: { app: postgres-auth }
  ports: [{ port: 5432, targetPort: 5432 }]
  type: ClusterIP
EOT

# Postgres Account-Datenbank
cat > "${BASE_OUT}/postgres-account.yaml" <<EOT
apiVersion: apps/v1
kind: Deployment
metadata: { name: postgres-account, namespace: ${NAMESPACE} }
spec:
  replicas: 1
  selector: { matchLabels: { app: postgres-account } }
  template:
    metadata: { labels: { app: postgres-account } }
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports: [{ containerPort: 5432 }]
        env:
        - name: POSTGRES_DB
          valueFrom: { configMapKeyRef: { name: app-config, key: POSTGRES_ACCOUNT_DB } }
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          valueFrom: { secretKeyRef: { name: app-secrets, key: POSTGRES_ACCOUNT_PASSWORD } }
        volumeMounts: [{ name: postgres-account-storage, mountPath: /var/lib/postgresql/data }]
      volumes: [{ name: postgres-account-storage, emptyDir: {} }]
---
apiVersion: v1
kind: Service
metadata: { name: postgres-account-service, namespace: ${NAMESPACE} }
spec:
  selector: { app: postgres-account }
  ports: [{ port: 5432, targetPort: 5432 }]
  type: ClusterIP
EOT

# Auth-Service
cat > "${BASE_OUT}/auth-service.yaml" <<EOT
apiVersion: apps/v1
kind: Deployment
metadata: { name: auth-service, namespace: ${NAMESPACE} }
spec:
  replicas: 2
  selector: { matchLabels: { app: auth-service } }
  template:
    metadata: { labels: { app: auth-service } }
    spec:
      containers:
      - name: auth-service
        image: bankportal/auth-service:latest
        imagePullPolicy: Never
        ports: [{ containerPort: 8081 }]
        env:
        - name: SPRING_PROFILES_ACTIVE
          valueFrom: { configMapKeyRef: { name: app-config, key: SPRING_PROFILES_ACTIVE } }
        - name: POSTGRES_AUTH_HOST
          valueFrom: { configMapKeyRef: { name: app-config, key: POSTGRES_AUTH_HOST } }
        - name: POSTGRES_AUTH_PASSWORD
          valueFrom: { secretKeyRef: { name: app-secrets, key: POSTGRES_AUTH_PASSWORD } }
        - name: JWT_SECRET
          valueFrom: { secretKeyRef: { name: app-secrets, key: JWT_SECRET } }
        livenessProbe: { httpGet: { path: /api/health, port: 8081 }, initialDelaySeconds: 60, periodSeconds: 30 }
        readinessProbe: { httpGet: { path: /api/health, port: 8081 }, initialDelaySeconds: 30, periodSeconds: 10 }
---
apiVersion: v1
kind: Service
metadata: { name: auth-service, namespace: ${NAMESPACE} }
spec:
  selector: { app: auth-service }
  ports: [{ port: 8081, targetPort: 8081 }]
  type: ClusterIP
EOT

# Account-Service
cat > "${BASE_OUT}/account-service.yaml" <<EOT
apiVersion: apps/v1
kind: Deployment
metadata: { name: account-service, namespace: ${NAMESPACE} }
spec:
  replicas: 2
  selector: { matchLabels: { app: account-service } }
  template:
    metadata: { labels: { app: account-service } }
    spec:
      containers:
      - name: account-service
        image: bankportal/account-service:latest
        imagePullPolicy: Never
        ports: [{ containerPort: 8082 }]
        env:
        - name: SPRING_PROFILES_ACTIVE
          valueFrom: { configMapKeyRef: { name: app-config, key: SPRING_PROFILES_ACTIVE } }
        - name: POSTGRES_ACCOUNT_HOST
          valueFrom: { configMapKeyRef: { name: app-config, key: POSTGRES_ACCOUNT_HOST } }
        - name: POSTGRES_ACCOUNT_PASSWORD
          valueFrom: { secretKeyRef: { name: app-secrets, key: POSTGRES_ACCOUNT_PASSWORD } }
        - name: AUTH_SERVICE_URL
          valueFrom: { configMapKeyRef: { name: app-config, key: AUTH_SERVICE_URL } }
        livenessProbe: { httpGet: { path: /api/health, port: 8082 }, initialDelaySeconds: 60, periodSeconds: 30 }
        readinessProbe: { httpGet: { path: /api/health, port: 8082 }, initialDelaySeconds: 30, periodSeconds: 10 }
---
apiVersion: v1
kind: Service
metadata: { name: account-service, namespace: ${NAMESPACE} }
spec:
  selector: { app: account-service }
  ports: [{ port: 8082, targetPort: 8082 }]
  type: ClusterIP
EOT

# Frontend
cat > "${BASE_OUT}/frontend.yaml" <<EOT
apiVersion: apps/v1
kind: Deployment
metadata: { name: frontend, namespace: ${NAMESPACE} }
spec:
  replicas: 2
  selector: { matchLabels: { app: frontend } }
  template:
    metadata: { labels: { app: frontend } }
    spec:
      containers:
      - name: frontend
        image: bankportal/frontend:latest
        imagePullPolicy: Never
        ports: [{ containerPort: 80 }]
---
apiVersion: v1
kind: Service
metadata: { name: frontend, namespace: ${NAMESPACE} }
spec:
  selector: { app: frontend }
  ports: [{ port: 80, targetPort: 80 }]
  type: NodePort
EOT

# Monitoring (Prometheus)
if [ "${MONITORING_ENABLED}" = "true" ]; then
  log "Erstelle Prometheus-Manifeste"
  cat > "${MON_OUT}/prometheus.yaml" <<EOT
apiVersion: v1
kind: ConfigMap
metadata: { name: prometheus-config, namespace: ${NAMESPACE} }
data:
  prometheus.yml: |
    global: { scrape_interval: 15s }
    scrape_configs:
    - job_name: auth-service
      static_configs: [ { targets: ['auth-service:8081'] } ]
      metrics_path: /actuator/prometheus
    - job_name: account-service
      static_configs: [ { targets: ['account-service:8082'] } ]
      metrics_path: /actuator/prometheus
---
apiVersion: apps/v1
kind: Deployment
metadata: { name: prometheus, namespace: ${NAMESPACE} }
spec:
  replicas: 1
  selector: { matchLabels: { app: prometheus } }
  template:
    metadata: { labels: { app: prometheus } }
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        args: [ "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus/", "--web.console.libraries=/etc/prometheus/console_libraries", "--web.console.templates=/etc/prometheus/consoles", "--web.enable-lifecycle" ]
        ports: [ { containerPort: 9090 } ]
        volumeMounts:
        - { name: prometheus-config, mountPath: /etc/prometheus/ }
        - { name: prometheus-storage, mountPath: /prometheus/ }
      volumes:
      - name: prometheus-config
        configMap: { name: prometheus-config }
      - name: prometheus-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata: { name: prometheus, namespace: ${NAMESPACE} }
spec:
  selector: { app: prometheus }
  ports: [ { port: 9090, targetPort: 9090 } ]
  type: NodePort
EOT
fi

# Monitoring (Grafana)
if [ "${MONITORING_ENABLED}" = "true" ]; then
  log "Erstelle Grafana-Manifeste"
  cat > "${MON_OUT}/grafana.yaml" <<EOT
apiVersion: apps/v1
kind: Deployment
metadata: { name: grafana, namespace: ${NAMESPACE} }
spec:
  replicas: 1
  selector: { matchLabels: { app: grafana } }
  template:
    metadata: { labels: { app: grafana } }
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports: [ { containerPort: 3000 } ]
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        - name: GF_INSTALL_PLUGINS
          value: "grafana-kubernetes-app"
        volumeMounts:
        - { name: grafana-storage, mountPath: /var/lib/grafana }
        - { name: grafana-config, mountPath: /etc/grafana/provisioning/ }
      volumes:
      - name: grafana-storage
        emptyDir: {}
      - name: grafana-config
        configMap: { name: grafana-config }
---
apiVersion: v1
kind: Service
metadata: { name: grafana, namespace: ${NAMESPACE} }
spec:
  selector: { app: grafana }
  ports: [ { port: 3000, targetPort: 3000 } ]
  type: NodePort
---
apiVersion: v1
kind: ConfigMap
metadata: { name: grafana-config, namespace: ${NAMESPACE} }
data:
  datasources.yml: |
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus:9090
      isDefault: true
EOT
fi

ok "Manifeste unter ${K8S_DIR} generiert"
