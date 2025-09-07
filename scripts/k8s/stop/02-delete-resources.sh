#!/usr/bin/env bash
# 02-delete-resources.sh — Kubernetes-Ressourcen löschen
# Löscht Services, Deployments und Namespace

. "$(dirname "$0")/../common.sh"
banner "🗑️ Ressourcen löschen"

if kubectl get ns "${NAMESPACE}" >/dev/null 2>&1; then
  if [ -d "${K8S_DIR}/monitoring" ]; then
    kubectl delete -f "${K8S_DIR}/monitoring/" --ignore-not-found=true || true
  fi
  for f in frontend.yaml account-service.yaml auth-service.yaml postgres-account.yaml postgres-auth.yaml secrets.yaml configmap.yaml; do
    [ -f "${K8S_DIR}/base/${f}" ] && kubectl delete -f "${K8S_DIR}/base/${f}" --ignore-not-found=true || true
  done
  kubectl delete ns "${NAMESPACE}" --ignore-not-found=true || true
  ok "Namespace und Ressourcen gelöscht"
else
  warn "Namespace ${NAMESPACE} existiert nicht"
fi
