#!/usr/bin/env bash

# 📘 Schritt 50: Deployment ins Kubernetes‑Cluster
# Anwenden der generierten YAMLs: Namespace/Config/Secrets, Datenbanken,
# Services/Deployments und optional Monitoring.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

deploy_to_kubernetes
echo -e "${GREEN}✅ Deploy ausgeführt – weiter mit Schritt 60 (Warten/Status)${NC}"
