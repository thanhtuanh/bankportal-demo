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
