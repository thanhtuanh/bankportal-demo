#!/usr/bin/env bash

# 📘 Schritt 80: Kubernetes Dashboard (optional)
# Installiert das offizielle Kubernetes Dashboard und erzeugt einen Admin‑Token.
# Tipp: Für produktive Umgebungen lieber RBAC/SSO sauber einrichten.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../start-k8s-demo.sh"

if [[ "${DASHBOARD_ENABLED:-true}" == "true" ]]; then
  install_k8s_dashboard
  show_access_info
else
  echo -e "${YELLOW}ℹ️  Dashboard ist deaktiviert – Schritt übersprungen${NC}"
fi

