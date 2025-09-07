#!/usr/bin/env bash
# 02-build-images.sh — Docker-Images für Bank Portal Services bauen
# Baut Images für auth-service, account-service und frontend

. "$(dirname "$0")/../common.sh"
banner "🔨 Docker-Images bauen"

set -e
docker build -t bankportal/auth-service:latest    ./auth-service    && ok "Auth Service gebaut"
docker build -t bankportal/account-service:latest ./account-service && ok "Account Service gebaut"
docker build -t bankportal/frontend:latest        ./frontend        && ok "Frontend gebaut"
