#!/usr/bin/env bash
# 06-wait.sh — Auf Deployments warten
# Beinhaltet Diagnose bei Timeout

. "$(dirname "$0")/../common.sh"
banner "⏳ Auf Deployments warten"

set +e
for d in auth-service account-service frontend; do
  if ! kubectl -n "${NAMESPACE}" wait --for=condition=available "deployment/${d}" --timeout=300s; then
    err "Timeout bei ${d} – Diagnose:"
    kubectl -n "${NAMESPACE}" get pods -l app="${d}" -o wide
    echo "--- describe deployment/${d} ---"
    kubectl -n "${NAMESPACE}" describe "deployment/${d}" || true
    echo "--- Neueste Pod-Logs ---"
    POD="$(kubectl -n "${NAMESPACE}" get pod -l app="${d}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
    [ -n "${POD:-}" ] && kubectl -n "${NAMESPACE}" logs "${POD}" --tail=200 || true
    exit 1
  fi
done

if [ "${MONITORING_ENABLED}" = "true" ]; then
  kubectl -n "${NAMESPACE}" wait --for=condition=available deployment/prometheus --timeout=180s 2>/dev/null || warn "Prometheus nicht verfügbar"
  kubectl -n "${NAMESPACE}" wait --for=condition=available deployment/grafana    --timeout=180s 2>/dev/null || warn "Grafana nicht verfügbar"
fi
set -e
ok "Alle Deployments verfügbar"
