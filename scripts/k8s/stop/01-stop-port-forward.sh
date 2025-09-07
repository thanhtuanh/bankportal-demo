#!/usr/bin/env bash
# 01-stop-port-forward.sh — Port-Forwarding stoppen
# Beendet alle kubectl port-forward Prozesse

. "$(dirname "$0")/../common.sh"
banner "🔗 Port-Forward stoppen"

pkill -f "kubectl port-forward" 2>/dev/null || true
ok "Port-Forward beendet"
