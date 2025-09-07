#!/usr/bin/env bash
# 03-delete-dashboard.sh — Kubernetes Dashboard entfernen
# Löscht Dashboard und Admin-Benutzer

. "$(dirname "$0")/../common.sh"
banner "📊 Dashboard entfernen"

kubectl delete clusterrolebinding admin-user --ignore-not-found=true || true
kubectl delete serviceaccount admin-user -n kubernetes-dashboard --ignore-not-found=true || true
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml --ignore-not-found=true >/dev/null 2>&1 || true
ok "Dashboard entfernt (falls vorhanden)"
