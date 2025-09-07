#!/usr/bin/env bash
# 08-status.sh — Deployment-Status anzeigen
# Zeigt Pods, Services und Deployments

. "$(dirname "$0")/../common.sh"
banner "📊 Status"

kubectl -n "${NAMESPACE}" get pods -o wide
kubectl -n "${NAMESPACE}" get svc
kubectl -n "${NAMESPACE}" get deploy
