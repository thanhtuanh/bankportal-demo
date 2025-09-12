#!/usr/bin/env bash

# 📘 Schritt 60: Auf Dienste warten und Status prüfen
# Wartet auf „bereit“ (Readiness) und zeigt den aktuellen Ressourcen‑Status an.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../start-k8s-demo.sh"

wait_for_services
show_status

echo -e "${GREEN}✅ Dienste bereit – weiter mit Schritt 70 (Port‑Forwarding)${NC}"

