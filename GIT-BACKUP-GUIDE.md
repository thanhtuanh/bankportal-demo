# 🔄 Git Backup System - Bank Portal

## 📋 Backup-Übersicht

Das Bank Portal Projekt verfügt über ein **2-Stand Backup-System** für einfache Versionsverwaltung:

### **Stand 1: `stand-1` Branch**
- **Beschreibung:** Original main Branch vor allen Änderungen
- **Inhalt:** Basis-Version des Bank Portals
- **Verwendung:** Fallback zur ursprünglichen Version

### **Stand 2: `stand-2` Branch** 
- **Beschreibung:** Production-ready Version mit allen Features
- **Inhalt:** 
  - ✅ Vollständige Swagger/OpenAPI Dokumentation
  - ✅ Behobene Health Checks
  - ✅ Spring Boot Actuator Integration
  - ✅ Bereinigte Projektstruktur
  - ✅ Optimierte CI/CD Pipeline
  - ✅ Professional Documentation

## 🚀 Schneller Branch-Wechsel

### **Einfacher Wechsel mit Script:**
```bash
./scripts/git-switch.sh
```

### **Manuelle Commands:**
```bash
# Zu Stand 1 wechseln (Original)
git checkout stand-1

# Zu Stand 2 wechseln (Production-ready)
git checkout stand-2

# Zu main wechseln (Aktuell)
git checkout main

# Zu Entwicklungsbranch wechseln
git checkout k8s
```

## 📊 Branch-Status

| Branch | Status | Beschreibung | Verwendung |
|--------|--------|--------------|------------|
| `main` | ✅ Aktuell | Hauptbranch mit allen Änderungen | Development |
| `stand-1` | 🔒 Backup | Original Version | Fallback |
| `stand-2` | 🚀 Production | Vollständige Features | Demo/Production |
| `k8s` | 🔧 Development | Entwicklungsbranch | Features |

## 🛠️ Nützliche Commands

### **Status prüfen:**
```bash
git branch -a                    # Alle Branches anzeigen
git log --oneline -5            # Letzte 5 Commits
git status                      # Aktueller Status
```

### **Änderungen verwalten:**
```bash
git stash                       # Änderungen temporär speichern
git stash pop                   # Änderungen wiederherstellen
git stash list                  # Gestashte Änderungen anzeigen
```

### **Remote synchronisieren:**
```bash
git pull origin main            # Main Branch aktualisieren
git push origin stand-1         # Stand 1 hochladen
git push origin stand-2         # Stand 2 hochladen
```

## 🎯 Anwendungsfälle

### **Für Bewerbungen:**
- **Stand 2** verwenden - zeigt vollständige Expertise
- Alle Features funktionsfähig und dokumentiert

### **Für Entwicklung:**
- **main** oder **k8s** Branch verwenden
- Neue Features entwickeln

### **Für Rollback:**
- **Stand 1** verwenden - zurück zur Basis-Version
- Sauberer Neustart möglich

## 🔄 Workflow-Beispiel

```bash
# 1. Aktuellen Stand prüfen
git branch --show-current

# 2. Zu Production-Version wechseln
./scripts/git-switch.sh
# Auswahl: 2 (stand-2)

# 3. Services starten
./scripts/deploy-local.sh

# 4. Zurück zu Development
./scripts/git-switch.sh  
# Auswahl: 3 (main)
```

## 📈 Backup-Strategie

- **Automatische Backups** bei wichtigen Meilensteinen
- **Tagged Releases** für Versioning
- **Remote Backup** auf GitHub
- **Lokale Branches** für schnellen Zugriff

**Mit diesem System können Sie jederzeit zwischen verschiedenen Projektständen wechseln!** 🎉
