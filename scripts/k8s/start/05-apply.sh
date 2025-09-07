#!/usr/bin/env bash
# 05-apply.sh — Kubernetes-Manifeste anwenden
# Wendet alle generierten Ressourcen auf den Cluster an

. "$(dirname "$0")/../common.sh"
banner "🚀 Ressourcen anwenden"

kubectl apply -f "${K8S_DIR}/base/namespace.yaml"
kubectl apply -f "${K8S_DIR}/base/configmap.yaml"
kubectl apply -f "${K8S_DIR}/base/secrets.yaml"
kubectl apply -f "${K8S_DIR}/base/postgres-auth.yaml"
kubectl apply -f "${K8S_DIR}/base/postgres-account.yaml"

# Auf Datenbanken warten
kubectl -n "${NAMESPACE}" wait --for=condition=ready pod -l app=postgres-auth --timeout=180s || true
kubectl -n "${NAMESPACE}" wait --for=condition=ready pod -l app=postgres-account --timeout=180s || true

kubectl apply -f "${K8S_DIR}/base/auth-service.yaml"
kubectl apply -f "${K8S_DIR}/base/account-service.yaml"
kubectl apply -f "${K8S_DIR}/base/frontend.yaml"

# Monitoring anwenden, wenn aktiviert
if [ "${MONITORING_ENABLED}" = "true" ] && compgen -G "${K8S_DIR}/monitoring/*.y*ml" > /dev/null; then
  kubectl apply -f "${K8S_DIR}/monitoring/"
else
  warn "Monitoring deaktiviert oder keine Manifeste gefunden – überspringen"
fi

ok "Ressourcen angewendet"
