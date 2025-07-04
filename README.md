# 🏦 Bank Portal Demo

![CI/CD Pipeline](https://github.com/thanhtuanh/bankportal-demo/workflows/Bank%20Portal%20CI%2FCD%20Pipeline/badge.svg)
![Last Commit](https://img.shields.io/github/last-commit/thanhtuanh/bankportal-demo)
![Repo Size](https://img.shields.io/github/repo-size/thanhtuanh/bankportal-demo)

## 📊 Aktueller Pipeline Status

| Service | Build Status | Last Updated |
|---------|-------------|--------------|
| 🔐 Auth Service | ✅ Build erfolgreich | $(date '+%d.%m.%Y %H:%M:%S') |
| 💰 Account Service | ✅ Build erfolgreich | $(date '+%d.%m.%Y %H:%M:%S') |
| 🌐 Frontend | ✅ Build erfolgreich | $(date '+%d.%m.%Y %H:%M:%S') |
| 🔍 SonarQube Analysis | ✅ Completed | $(date '+%d.%m.%Y %H:%M:%S') |
| 🐳 Docker Images | ✅ Pushed to GHCR | $(date '+%d.%m.%Y %H:%M:%S') |

## 🚀 Quick Links

- **🔍 Code-Qualität:** [SonarCloud Dashboard](https://sonarcloud.io/organizations/thanhtuanh/projects)
- **🐳 Container Images:** [GitHub Container Registry](https://github.com/thanhtuanh/bankportal-demo/pkgs)
- **📋 CI/CD Pipeline:** [GitHub Actions](https://github.com/thanhtuanh/bankportal-demo/actions)
- **📊 Pipeline Reports:** [Latest Run](https://github.com/thanhtuanh/bankportal-demo/actions/runs/16068252694)

## 🏗️ Architektur

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Frontend  │───▶│ Auth Service │───▶│ PostgreSQL  │
│   (React)   │    │(Spring Boot) │    │ Database    │
└─────────────┘    └──────────────┘    └─────────────┘
                           │
                           ▼
                   ┌──────────────┐    ┌─────────────┐
                   │Account Service│───▶│ PostgreSQL  │
                   │(Spring Boot) │    │ Database    │
                   └──────────────┘    └─────────────┘
```

## 📈 Letzte Aktivität

- **Letzter Commit:** `4ad6ae2541b7ab87eef7bb39dcc56f5330c7fc64`
- **Branch:** `main`
- **Author:** thanhtuanh
- **Build Zeit:** $(date '+%d.%m.%Y %H:%M:%S')

## 🛠️ Technologie Stack

| Komponente | Technologie | Version |
|------------|-------------|---------|
| Frontend | React + TypeScript | 18.x |
| Backend | Spring Boot | 3.x |
| Database | PostgreSQL | 15.x |
| Build Tool | Maven | 3.x |
| Java | OpenJDK | 17 |
| Code Quality | SonarCloud | Latest |
| CI/CD | GitHub Actions | Latest |
| Container | Docker + GHCR | Latest |

## 🎯 Entwicklungsstatus

- ✅ **CI/CD Pipeline** - Vollständig implementiert
- ✅ **Automatische Tests** - Frontend + Backend
- ✅ **Code-Qualitätsprüfung** - SonarCloud integriert
- ✅ **Container Deployment** - Docker Images in GHCR
- ⏳ **E2E Tests** - Geplant
- ⏳ **Monitoring** - In Vorbereitung
- ⏳ **Production Deployment** - Nächste Phase

---
*🤖 Automatisch aktualisiert durch GitHub Actions - $(date '+%d.%m.%Y %H:%M:%S')*

<!-- CI/CD STATUS START -->

-----

## 🤖 CI/CD Pipeline Status

![CI/CD Pipeline](https://github.com/thanhtuanh/bankportal-demo/workflows/Bank%20Portal%20CI%2FCD%20Pipeline/badge.svg)
![Last Commit](https://img.shields.io/github/last-commit/thanhtuanh/bankportal-demo)
![Repo Size](https://img.shields.io/github/repo-size/thanhtuanh/bankportal-demo)

### 📊 Aktueller Build Status

| Service | Status | Letztes Update |
|---------|--------|----------------|
| 🔐 Auth Service | ✅ Build erfolgreich | 04.07.2025 08:05:08 |
| 💰 Account Service | ✅ Build erfolgreich | 04.07.2025 08:05:08 |
| 🌐 Frontend | ✅ Build erfolgreich | 04.07.2025 08:05:08 |
| 🔍 SonarQube Analyse | ✅ Abgeschlossen | 04.07.2025 08:05:08 |
| 🐳 Docker Images | ✅ Zu GHCR gepusht | 04.07.2025 08:05:08 |

### 🔗 Entwickler-Links

- **🔍 Code-Qualität:** [SonarCloud Dashboard](https://sonarcloud.io/organizations/thanhtuanh/projects)
- **🐳 Container Images:** [GitHub Container Registry](https://github.com/thanhtuanh/bankportal-demo/pkgs)
- **📋 CI/CD Pipeline:** [GitHub Actions](https://github.com/thanhtuanh/bankportal-demo/actions)
- **📊 Pipeline Report:** [Letzter Lauf](https://github.com/thanhtuanh/bankportal-demo/actions/runs/16068754479)

### 📈 Letzte Pipeline-Aktivität

- **Letzter Commit:** `c6a1e2a28db0c5c9e5d34185ce54e09dffd68663`
- **Branch:** `main`
- **Autor:** ${AUTHOR_NAME}
- **Build-Zeit:** 04.07.2025 08:05:08
- **Ausgelöst durch:** push

### 🛠️ DevOps Pipeline

| Phase | Tool | Status |
|-------|------|--------|
| Build | Maven + npm | ✅ |
| Tests | JUnit + Jest | ✅ |
| Code-Qualität | SonarCloud | ✅ |
| Containerisierung | Docker + GHCR | ✅ |
| CI/CD | GitHub Actions | ✅ |

> **Hinweis:** Diese Pipeline demonstriert moderne DevOps-Praktiken für die Bankenbranche mit automatisierten Tests, Code-Qualitätsprüfungen und sicherer Container-Bereitstellung.

-----
*🤖 Automatisch aktualisiert durch GitHub Actions Pipeline - 04.07.2025 08:05:08*

<!-- CI/CD STATUS END -->
