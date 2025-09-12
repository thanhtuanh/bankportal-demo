#!/bin/bash

# 🔐 GitHub Secrets Synchronisation Script
# Überträgt .env Variablen automatisch zu GitHub Repository Secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="thanhtuanh"
REPO_NAME="bankportal-demo"
# Allow override via ENV_FILE env var; default to .env.production in current dir
ENV_FILE="${ENV_FILE:-.env.production}"

echo -e "${BLUE}🔐 GitHub Secrets Synchronisation${NC}"
echo -e "${BLUE}===================================${NC}"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) ist nicht installiert!${NC}"
    echo -e "${YELLOW}Installation: https://cli.github.com/${NC}"
    exit 1
fi

# Ensure auth (use GH_TOKEN if available for non-interactive login)
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}🔐 GitHub Authentifizierung erforderlich...${NC}"
    if [[ -n "${GH_TOKEN:-}" ]]; then
        echo -e "${YELLOW}🔑 Verwende GH_TOKEN für Login (non-interactive)${NC}"
        gh auth login --with-token <<< "$GH_TOKEN"
    else
        gh auth login
    fi
fi

# Check if .env file exists
if [[ ! -f "$ENV_FILE" ]]; then
    echo -e "${RED}❌ $ENV_FILE nicht gefunden!${NC}"
    echo -e "${YELLOW}Erstellen Sie zuerst eine .env.production Datei oder setzen Sie ENV_FILE=/pfad/zur/datei${NC}"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI ist verfügbar und authentifiziert${NC}"
echo -e "${GREEN}✅ $ENV_FILE gefunden${NC}"
echo ""

# Function to set GitHub secret
set_github_secret() {
    local key=$1
    local value=$2
    
    echo -e "${CYAN}📤 Setze Secret: $key${NC}"
    
    if gh secret set "$key" --body "$value" --repo "$REPO_OWNER/$REPO_NAME"; then
        echo -e "${GREEN}   ✅ $key erfolgreich gesetzt${NC}"
    else
        echo -e "${RED}   ❌ Fehler beim Setzen von $key${NC}"
        return 1
    fi
}

# Read .env file and set secrets
echo -e "${YELLOW}📋 Lese $ENV_FILE und setze GitHub Secrets...${NC}"
echo ""

# Counter for statistics
success_count=0
error_count=0

while IFS='=' read -r key value || [[ -n "$key" ]]; do
    # Skip empty lines and comments
    if [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    # Remove leading/trailing whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    
    # Skip if key or value is empty
    if [[ -z "$key" || -z "$value" ]]; then
        continue
    fi

    # Safety: never push GitHub auth tokens as repo secrets
    if [[ "$key" =~ ^GH_.*TOKEN$ ]]; then
        echo -e "${YELLOW}⏭️  Überspringe potentiellen Auth-Token Key: $key${NC}"
        continue
    fi
    
    # Remove quotes from value if present
    value=$(echo "$value" | sed 's/^["'\'']//' | sed 's/["'\'']$//')
    # Skip obvious placeholder values
    if [[ "$value" == "..." || "$value" == "CHANGE_ME" || "$value" == *"<CHANGE"* || "$value" == *"TBD"* ]]; then
        echo -e "${YELLOW}⏭️  Überspringe Platzhalterwert für $key${NC}"
        continue
    fi
    
    # Set the secret
    if set_github_secret "$key" "$value"; then
        ((success_count++))
    else
        ((error_count++))
    fi
    
done < "$ENV_FILE"

echo ""
echo -e "${BLUE}📊 Synchronisation abgeschlossen:${NC}"
echo -e "${GREEN}   ✅ Erfolgreich: $success_count Secrets${NC}"
if [[ $error_count -gt 0 ]]; then
    echo -e "${RED}   ❌ Fehler: $error_count Secrets${NC}"
fi

echo ""
echo -e "${YELLOW}💡 Tipps:${NC}"
echo -e "${CYAN}   • Secrets anzeigen: gh secret list --repo $REPO_OWNER/$REPO_NAME${NC}"
echo -e "${CYAN}   • Secret löschen: gh secret delete SECRET_NAME --repo $REPO_OWNER/$REPO_NAME${NC}"
echo -e "${CYAN}   • GitHub Actions verwenden diese Secrets automatisch${NC}"

echo ""
echo -e "${GREEN}🎉 GitHub Secrets Synchronisation abgeschlossen!${NC}"
