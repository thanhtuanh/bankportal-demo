#!/usr/bin/env bash
# 07-dashboard.sh — Kubernetes Dashboard installieren
# Optionale Dashboard-Einrichtung mit Admin-Zugriff

. "$(dirname "$0")/../common.sh"
banner "📊 Kubernetes Dashboard installieren"

if [ "${DASHBOARD_ENABLED}" != "true" ]; then
  warn "Dashboard deaktiviert"
  exit 0
fi

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml >/dev/null 2>&1
cat <<'YAML' | kubectl apply -f - >/dev/null 2>&1
apiVersion: v1
kind: ServiceAccount
metadata: { name: admin-user, namespace: kubernetes-dashboard }
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: { name: admin-user }
roleRef: { apiGroup: rbac.authorization.k8s.io, kind: ClusterRole, name: cluster-admin }
subjects: [ { kind: ServiceAccount, name: admin-user, namespace: kubernetes-dashboard } ]
YAML

ok "Dashboard installiert (Token: kubectl -n kubernetes-dashboard create token admin-user)"
