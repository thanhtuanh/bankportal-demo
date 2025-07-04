# 🔍 SonarCloud Setup Guide

## 📋 Übersicht

SonarCloud ist **temporär deaktiviert** in der CI/CD Pipeline, bis die Projekte korrekt konfiguriert sind.

## 🚀 SonarCloud Aktivierung (Optional)

### **Schritt 1: SonarCloud Account erstellen**
1. Gehe zu [SonarCloud.io](https://sonarcloud.io)
2. Melde dich mit GitHub Account an
3. Erstelle eine neue Organization

### **Schritt 2: Projekte erstellen**
1. **Auth Service Projekt:**
   - Project Key: `bankportal-demo-auth-service`
   - Project Name: `Bank Portal Auth Service`

2. **Account Service Projekt:**
   - Project Key: `bankportal-demo-account-service`
   - Project Name: `Bank Portal Account Service`

### **Schritt 3: GitHub Secrets konfigurieren**
1. Gehe zu GitHub Repository → Settings → Secrets
2. Füge hinzu:
   ```
   SONAR_TOKEN: <your-sonarcloud-token>
   ```

### **Schritt 4: CI/CD Pipeline aktivieren**
In `.github/workflows/ci-cd.yml`:

```yaml
# Ändere diese Zeilen:
if: false  # Temporarily disabled

# Zu:
# if: false  # Temporarily disabled (entfernen)
```

### **Schritt 5: Organization anpassen**
In der CI/CD Pipeline die Organization anpassen:
```yaml
-Dsonar.organization=your-org  # Ersetze mit deiner Organization
```

## 🎯 Warum SonarCloud?

### **Für Bewerbungen:**
- ✅ **Code Quality** Demonstration
- ✅ **Security Scanning** 
- ✅ **Technical Debt** Monitoring
- ✅ **Professional Standards**

### **Für Entwicklung:**
- ✅ **Automated Code Review**
- ✅ **Bug Detection**
- ✅ **Security Vulnerabilities**
- ✅ **Code Coverage**

## 🔧 Alternative: Lokale SonarQube

Falls SonarCloud nicht gewünscht:

```bash
# Docker SonarQube starten
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest

# Maven Analyse
mvn sonar:sonar \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=admin \
  -Dsonar.password=admin
```

## 📊 Aktueller Status

| Service | SonarCloud Status | Grund |
|---------|------------------|-------|
| Auth Service | 🔧 Deaktiviert | Projekt nicht konfiguriert |
| Account Service | 🔧 Deaktiviert | Projekt nicht konfiguriert |
| CI/CD Pipeline | ✅ Funktional | Läuft ohne SonarCloud |

## 🎯 Nächste Schritte

1. **Optional:** SonarCloud Account erstellen
2. **Optional:** Projekte konfigurieren  
3. **Optional:** Pipeline aktivieren
4. **Empfohlen:** Projekt funktioniert auch ohne SonarCloud

**Die CI/CD Pipeline läuft vollständig ohne SonarCloud - es ist ein optionales Feature für erweiterte Code-Qualitäts-Analyse.**
