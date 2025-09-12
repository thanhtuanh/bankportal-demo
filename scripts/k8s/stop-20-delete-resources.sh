#!/usr/bin/env bash

# 🛑 Schritt Stop-20: Kubernetes-Ressourcen löschen
# Entfernt Deployments/Services/Config/Secrets (und optional Monitoring).

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../stop-k8s-demo.sh"

delete_k8s_resources
echo -e "${GREEN}✅ Ressourcen gelöscht${NC}"

