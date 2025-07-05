# 🔐 GitHub Secrets Setup Guide

## 📋 **Übersicht**

Diese Anleitung zeigt, wie Sie Environment-Variablen automatisch als GitHub Secrets einrichten und in CI/CD Pipelines verwenden.

## 🚀 **Automatische Synchronisation**

### **1. 🤖 Mit GitHub CLI (Lokal)**

#### **Setup:**
```bash
# GitHub CLI installieren
# macOS: brew install gh
# Windows: winget install GitHub.cli
# Linux: siehe https://cli.github.com/

# Authentifizierung
gh auth login

# Secrets synchronisieren
./scripts/sync-github-secrets.sh
```

#### **Script-Features:**
- ✅ **Automatisches Lesen** von .env.production
- ✅ **Batch-Upload** aller Variablen
- ✅ **Fehlerbehandlung** und Statistiken
- ✅ **Sichere Übertragung** ohne lokale Speicherung

### **2. 🔄 Mit GitHub Actions (Automatisch)**

#### **Workflow-Trigger:**
```yaml
# Manuell über GitHub UI
workflow_dispatch:
  inputs:
    environment: [development, staging, production]
    force_update: boolean

# Automatisch bei .env.example Änderungen
push:
  paths: ['.env.example', '.env.template']
```

#### **Verwendung:**
1. **GitHub Repository** → **Actions** Tab
2. **"Sync Environment Secrets"** Workflow auswählen
3. **"Run workflow"** klicken
4. **Environment** auswählen (production empfohlen)
5. **Run workflow** bestätigen

## 🔧 **Manuelle Einrichtung**

### **Erforderliche Secrets:**

#### **Production Secrets:**
```bash
# Database Credentials
PRODUCTION_POSTGRES_AUTH_PASSWORD=secure-auth-db-password
PRODUCTION_POSTGRES_ACCOUNT_PASSWORD=secure-account-db-password

# JWT Configuration
PRODUCTION_JWT_SECRET=super-secure-jwt-secret-64-chars-minimum

# Service URLs
PRODUCTION_AUTH_SERVICE_URL=https://auth.bankportal.com
PRODUCTION_ACCOUNT_SERVICE_URL=https://account.bankportal.com
PRODUCTION_FRONTEND_URL=https://bankportal.com

# Database Hosts (für Cloud-Deployment)
PRODUCTION_DB_AUTH_HOST=auth-db.region.rds.amazonaws.com
PRODUCTION_DB_ACCOUNT_HOST=account-db.region.rds.amazonaws.com

# Monitoring
PRODUCTION_GRAFANA_PASSWORD=secure-grafana-password
PRODUCTION_PROMETHEUS_PASSWORD=secure-prometheus-password
```

#### **Staging Secrets:**
```bash
STAGING_POSTGRES_AUTH_PASSWORD=staging-auth-password
STAGING_POSTGRES_ACCOUNT_PASSWORD=staging-account-password
STAGING_JWT_SECRET=staging-jwt-secret
STAGING_AUTH_SERVICE_URL=https://auth-staging.bankportal.com
STAGING_ACCOUNT_SERVICE_URL=https://account-staging.bankportal.com
STAGING_FRONTEND_URL=https://staging.bankportal.com
```

### **GitHub UI Setup:**
1. **Repository** → **Settings** → **Secrets and variables** → **Actions**
2. **"New repository secret"** klicken
3. **Name** und **Value** eingeben
4. **"Add secret"** klicken

## 🔄 **CI/CD Integration**

### **Secrets in GitHub Actions verwenden:**

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Setup Environment
        run: |
          # Secrets als Environment-Variablen verwenden
          echo "JWT_SECRET=${{ secrets.PRODUCTION_JWT_SECRET }}" >> .env.production
          echo "DB_PASSWORD=${{ secrets.PRODUCTION_POSTGRES_AUTH_PASSWORD }}" >> .env.production
        
      - name: Deploy with Secrets
        env:
          # Secrets direkt als Umgebungsvariablen
          JWT_SECRET: ${{ secrets.PRODUCTION_JWT_SECRET }}
          DB_PASSWORD: ${{ secrets.PRODUCTION_POSTGRES_AUTH_PASSWORD }}
        run: |
          docker-compose -f docker-compose-backup.yml up -d
```

### **Docker Compose Integration:**
```yaml
# docker-compose-production.yml
services:
  auth-service:
    environment:
      JWT_SECRET: ${JWT_SECRET}
      SPRING_DATASOURCE_PASSWORD: ${DB_AUTH_PASSWORD}
    # Secrets werden von GitHub Actions als ENV-Vars gesetzt
```

## 🛡️ **Sicherheits-Best Practices**

### **✅ Do's:**
- **Starke, zufällige Secrets** generieren
- **Environment-spezifische Prefixes** verwenden
- **Regelmäßige Rotation** der Secrets
- **Least-Privilege Prinzip** befolgen

### **❌ Don'ts:**
- **Niemals Secrets in Logs** ausgeben
- **Keine Secrets in Code** committen
- **Keine Secrets in Pull Requests** diskutieren
- **Keine Wiederverwendung** zwischen Environments

### **🔐 Secret-Generierung:**
```bash
# Sichere JWT Secrets generieren
openssl rand -hex 64

# Sichere Passwörter generieren
openssl rand -base64 32

# UUID für eindeutige IDs
uuidgen
```

## 📊 **Monitoring & Validation**

### **Secret-Status prüfen:**
```bash
# Mit GitHub CLI
gh secret list

# Specific secret info (ohne Wert zu zeigen)
gh secret list | grep PRODUCTION_JWT_SECRET
```

### **CI/CD Validation:**
```yaml
- name: Validate Secrets
  run: |
    # Prüfen ob Secrets verfügbar sind (ohne Werte zu zeigen)
    if [[ -z "${{ secrets.PRODUCTION_JWT_SECRET }}" ]]; then
      echo "❌ PRODUCTION_JWT_SECRET missing"
      exit 1
    fi
    echo "✅ All required secrets available"
```

## 🔄 **Secret-Rotation**

### **Automatische Rotation (Erweitert):**
```yaml
# .github/workflows/rotate-secrets.yml
name: Rotate Secrets
on:
  schedule:
    - cron: '0 2 1 * *'  # Monatlich am 1. um 2 Uhr
  workflow_dispatch:

jobs:
  rotate:
    runs-on: ubuntu-latest
    steps:
      - name: Generate New Secrets
        run: |
          NEW_JWT_SECRET=$(openssl rand -hex 64)
          NEW_DB_PASSWORD=$(openssl rand -base64 32)
          
          # Update secrets
          echo "$NEW_JWT_SECRET" | gh secret set PRODUCTION_JWT_SECRET
          echo "$NEW_DB_PASSWORD" | gh secret set PRODUCTION_POSTGRES_AUTH_PASSWORD
```

## 🚀 **Deployment-Workflows**

### **Production Deployment mit Secrets:**
```yaml
deploy-production:
  environment: production
  steps:
    - name: Deploy with GitHub Secrets
      env:
        JWT_SECRET: ${{ secrets.PRODUCTION_JWT_SECRET }}
        DB_AUTH_PASSWORD: ${{ secrets.PRODUCTION_POSTGRES_AUTH_PASSWORD }}
        DB_ACCOUNT_PASSWORD: ${{ secrets.PRODUCTION_POSTGRES_ACCOUNT_PASSWORD }}
      run: |
        # Secrets sind als Umgebungsvariablen verfügbar
        docker-compose -f docker-compose-backup.yml up -d
        
        # Health checks mit secret-basierten URLs
        curl -f ${{ secrets.PRODUCTION_AUTH_SERVICE_URL }}/api/health
```

## 📚 **Weiterführende Ressourcen**

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub CLI Secrets Commands](https://cli.github.com/manual/gh_secret)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

---

## 🎯 **Quick Commands**

```bash
# Secrets synchronisieren
./scripts/sync-github-secrets.sh

# Secrets auflisten
gh secret list

# Einzelnes Secret setzen
gh secret set SECRET_NAME --body "secret-value"

# Secret löschen
gh secret delete SECRET_NAME

# Workflow manuell starten
gh workflow run "Sync Environment Secrets"
```

**🔐 Mit diesem Setup sind Ihre Secrets sicher und automatisch in CI/CD verfügbar!**
