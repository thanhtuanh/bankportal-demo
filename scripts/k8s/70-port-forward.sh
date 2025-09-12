#!/usr/bin/env bash

# 📘 Schritt 70: Port‑Forwarding einrichten
# Leitet Service‑Ports (Frontend/Auth/Account, optional Monitoring) lokal durch,
# damit du die Web‑UIs im Browser öffnen kannst.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../start-k8s-demo.sh"

setup_port_forwarding

echo -e "${GREEN}✅ Port‑Forwarding aktiv – weiter mit Schritt 80 (Dashboard, optional)${NC}"

