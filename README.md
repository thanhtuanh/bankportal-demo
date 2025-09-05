🏦 Bank Portal - Moderne Banking-Plattform

Enterprise-Grade Banking-LösungJava 17 • Spring Boot 3.4 • Angular 18 • PostgreSQL 15 • Docker • Kubernetes



🚀 Schnellstart
git clone https://github.com/thanhtuanh/bankportal-demo.git
cd bankportal-demo
./start-demo.sh

Bereit in 2 Minuten! → http://localhost:4200

🎯 Hauptfunktionen



Komponente
Technologie
Port
Beschreibung



Frontend
Angular 18
4200
Moderne Banking-Oberfläche


Auth API
Spring Boot
8081
JWT-Authentifizierung


Account API
Spring Boot
8082
Kontenverwaltung


Datenbank
PostgreSQL 15
5433/5434
ACID-Transaktionen



🏗️ Architektur
┌─────────────────────────────────────────────────────────┐
│                    🌐 FRONTEND LAYER                    │
│  Angular 18 SPA  │  nginx Proxy  │  SSL/TLS Security    │
│  • TypeScript    │  • Load Bal.  │  • HTTPS/WSS         │
│  • Responsive UI │  • Caching    │  • CORS Headers      │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────┐
│                🔧 API GATEWAY & SECURITY                │
│  JWT Auth       │  Rate Limiting  │  API Routing        │
│  • Token Valid. │  • DDoS Protect │  • Load Balance     │
│  • User Session │  • Monitoring   │  • Health Checks    │
└─────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────-┐
│ 🔐 Auth Service │  │💼 Account Service│ │🔮 Future Services│
│                 │  │                 │  │                  │
│ • User Mgmt     │  │ • Account CRUD  │  │ • Notifications  │
│ • JWT Tokens    │  │ • Money Transfer│  │ • Analytics      │
│ • Registration  │  │ • Balance Check │  │ • Reporting      │
│ • Spring Boot   │  │ • Spring Boot   │  │ • Extensible     │
│ • Port 8081     │  │ • Port 8082     │  │ • Port 808x      │
└─────────────────┘  └─────────────────┘  └─────────────────-┘
              │               │               │
              ▼               ▼               ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   PostgreSQL    │  │   PostgreSQL    │  │   Monitoring    │
│   Auth Database │  │ Account Database│  │   & Backup      │
│                 │  │                 │  │                 │
│ • Users/Roles   │  │ • Accounts      │  │ • Prometheus    │
│ • JWT Sessions  │  │ • Transactions  │  │ • Grafana       │
│ • Audit Logs    │  │ • WAL Archive   │  │ • Backup System │
│ • Port 5433     │  │ • Port 5434     │  │ • Health Checks │
└─────────────────┘  └─────────────────┘  └─────────────────┘

Microservices-Architektur • JWT-Sicherheit • Docker-Containerisiert

💼 Demo-Workflow
1. Benutzerregistrierung & Anmeldung
curl -X POST http://localhost:8081/api/auth/register \
  -d '{"username": "demo", "password": "demo123"}'

2. Kontenverwaltung
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"owner": "demo", "balance": 1000.0}'

3. Geldtransfer
curl -X POST http://localhost:8082/api/accounts/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"fromAccountId": 1, toAccountId": 2, "amount": 100.0}'


🔧 Entwicklung
Lokales Setup
# Entwicklung
docker-compose up -d

# Produktion mit Backup
docker-compose -f docker-compose-backup.yml up -d

# Kubernetes Demo
./scripts/start-k8s-demo.sh

Technologie-Stack

Backend: Java 17, Spring Boot 3.4, Spring Security
Frontend: Angular 18, TypeScript, RxJS
Datenbank: PostgreSQL 15, JPA/Hibernate
DevOps: Docker, Kubernetes, GitHub Actions
Sicherheit: JWT, BCrypt, CORS-Schutz


🚀 Produktionsbereit
Enterprise-Funktionen

✅ Microservices-Architektur
✅ JWT-Authentifizierung & Autorisierung
✅ ACID-Datenbanktransaktionen
✅ Automatisierte Sicherung & Wiederherstellung
✅ Health Checks & Monitoring
✅ CI/CD-Pipeline
✅ Kubernetes-Deployment
✅ Sicherheits-Best Practices

Deployment-Optionen

Docker Compose - Lokale Entwicklung
Kubernetes - Container-Orchestrierung
Cloud Ready - AWS, Azure, GCP kompatibel


📚 Dokumentation



Anleitung
Beschreibung



Frontend-Anleitung
Web-App Benutzerhandbuch


API-Tests
REST-API Beispiele


Entwickler-Anleitung
Technische Dokumentation


GitHub Secrets
Automatisierte Secrets-Verwaltung


Kubernetes-Lernen
K8s Lernpfad


Schnellreferenz
Wichtige Befehle



🎓 DevOps-Showcase
Dieses Projekt demonstriert:

Moderne Java-Entwicklung (Spring Boot 3.4, Java 17)
Frontend-Engineering (Angular 18, TypeScript)
Microservices-Design (Service-Trennung, API Gateway)
Datenbank-Management (PostgreSQL, Transaktionen, Backup)
Container-Technologie (Docker, Kubernetes)
CI/CD-Implementierung (GitHub Actions, Automatisierte Tests)
Sicherheits-Implementierung (JWT, Secrets-Management)
Produktions-Betrieb (Monitoring, Health Checks, Recovery)


🛑 Demo-Stoppen und Bereinigung
Nach dem Ausführen von ./scripts/stop-k8s-demo.sh wird der Kubernetes-Namespace bankportal sowie alle darin enthaltenen Ressourcen (z. B. Deployments, Services) gelöscht. Der lokale Ordner k8s (oder demo-manifests, wenn umbenannt) wird ebenfalls entfernt, da er temporäre Manifeste enthält, die bei Bedarf neu generiert werden. Bei Verwendung von Docker Desktop mit integriertem Kubernetes können jedoch Container übrig bleiben. Folgendes ist zu beachten:

Verbleibende Container: Das Skript löscht nicht automatisch Docker-Container. Um sie zu bereinigen:docker rm -f $(docker ps -a -q)


Hinweis: Dies entfernt alle Container (laufend oder gestoppt). Überprüfe vorher mit docker ps -a, um sicherzugehen, dass keine anderen Projekte betroffen sind.


Docker Desktop zurücksetzen: Für eine vollständige Bereinigung:
Öffne Docker Desktop.
Gehe zu Preferences > Kubernetes, deaktiviere Kubernetes und bestätige.
Gehe zu Preferences > Reset, wähle Reset to factory defaults und starte neu.
Aktiviere Kubernetes wieder und warte auf die Bereitschaft.


Ressourcenanpassung: Stelle sicher, dass Docker Desktop mindestens 4 GB RAM zugewiesen hat (Preferences > Resources > Memory > 4096 MiB), um Stabilitätsprobleme zu vermeiden.
Neustart: Nach der Bereinigung starte den Demo mit ./scripts/start-k8s-demo.sh neu.

Tipp: Erstelle vor dem Stoppen ein Backup des k8s-Ordners, falls du Anpassungen gemacht hast:
cp -r k8s k8s_backup_$(date +%Y%m%d_%H%M%S)

Oder nutze ./scripts/stop-k8s-demo.sh --keep-files, um den Ordner zu behalten.

🛠️ Schnellbefehle
# Demo starten
./start-demo.sh

# Kubernetes Demo
./scripts/start-k8s-demo.sh

# Services anzeigen
docker-compose ps

# Health Checks
curl http://localhost:8081/api/health
curl http://localhost:8082/api/health

# Logs anzeigen
docker-compose logs -f

# Demo stoppen
docker-compose down
./scripts/stop-k8s-demo.sh


📞 Kontakt

GitHub: thanhtuanh/bankportal-demo
Issues: Bugs melden
Lizenz: MIT


🎯 Enterprise-Grade Banking-Plattform, die moderne Entwicklungspraktiken und produktionsbereite Architektur demonstriert.