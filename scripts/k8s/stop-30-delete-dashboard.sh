#!/usr/bin/env bash

# 🛑 Schritt Stop-30: Kubernetes Dashboard entfernen
# Entfernt Admin-Account und Dashboard-Deployment.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../stop-k8s-demo.sh"

delete_k8s_dashboard
echo -e "${GREEN}✅ Dashboard entfernt${NC}"

