#!/usr/bin/env bash

# 🛑 Schritt Stop-10: Port‑Forwarding beenden
# Beendet lokale Port‑Weiterleitungen (kubectl port-forward), damit Ports frei werden.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../stop-k8s-demo.sh"

stop_port_forwarding
echo -e "${GREEN}✅ Port‑Forwarding beendet${NC}"

