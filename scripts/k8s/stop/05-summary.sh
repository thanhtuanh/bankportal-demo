#!/usr/bin/env bash
# 05-summary.sh — Cleanup-Zusammenfassung anzeigen
# Prüft finale Status und zeigt Summary

. "$(dirname "$0")/../common.sh"
banner "✅ Cleanup abgeschlossen"

kubectl get ns "${NAMESPACE}" >/dev/null 2>&1 && warn "Namespace ${NAMESPACE} existiert noch" || ok "Namespace entfernt"
pgrep -f "kubectl port-forward" >/dev/null && warn "Port-Forwards noch aktiv" || ok "Keine Port-Forwards aktiv"
