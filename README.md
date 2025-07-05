# 🏦 Bank Portal - Modern Banking Platform

> **Enterprise-Grade Banking Solution**  
> Java 17 • Spring Boot 3.4 • Angular 18 • PostgreSQL 15 • Docker • Kubernetes

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.java.net/projects/jdk/17/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Angular](https://img.shields.io/badge/Angular-18-red.svg)](https://angular.io/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

---

## 🚀 **Quick Start**

```bash
git clone https://github.com/thanhtuanh/bankportal-demo.git
cd bankportal-demo
./start-demo.sh
```

**Ready in 2 minutes!** → http://localhost:4200

---

## 🎯 **Key Features**

| Component | Technology | Port | Description |
|-----------|------------|------|-------------|
| **Frontend** | Angular 18 | 4200 | Modern Banking UI |
| **Auth API** | Spring Boot | 8081 | JWT Authentication |
| **Account API** | Spring Boot | 8082 | Account Management |
| **Database** | PostgreSQL 15 | 5433/5434 | ACID Transactions |

---

## 🏗️ **Architecture**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Angular   │───▶│   Gateway   │───▶│Microservices│
│   Frontend  │    │   (nginx)   │    │Auth+Account │
└─────────────┘    └─────────────┘    └─────────────┘
                                              │
                                      ┌─────────────┐
                                      │ PostgreSQL  │
                                      │  Databases  │
                                      └─────────────┘
```

**Microservices Architecture** • **JWT Security** • **Docker Containerized**

---

## 💼 **Demo Workflow**

### 1. **User Registration & Login**
```bash
curl -X POST http://localhost:8081/api/auth/register \
  -d '{"username": "demo", "password": "demo123"}'
```

### 2. **Account Management**
```bash
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"owner": "demo", "balance": 1000.0}'
```

### 3. **Money Transfer**
```bash
curl -X POST http://localhost:8082/api/accounts/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"fromAccountId": 1, "toAccountId": 2, "amount": 100.0}'
```

---

## 🔧 **Development**

### **Local Setup**
```bash
# Development
docker-compose up -d

# Production with Backup
docker-compose -f docker-compose-backup.yml up -d
```

### **Tech Stack**
- **Backend:** Java 17, Spring Boot 3.4, Spring Security
- **Frontend:** Angular 18, TypeScript, RxJS
- **Database:** PostgreSQL 15, JPA/Hibernate
- **DevOps:** Docker, Kubernetes, GitHub Actions
- **Security:** JWT, BCrypt, CORS Protection

---

## 🚀 **Production Ready**

### **Enterprise Features**
- ✅ **Microservices Architecture**
- ✅ **JWT Authentication & Authorization**
- ✅ **ACID Database Transactions**
- ✅ **Automated Backup & Recovery**
- ✅ **Health Checks & Monitoring**
- ✅ **CI/CD Pipeline**
- ✅ **Kubernetes Deployment**
- ✅ **Security Best Practices**

### **Deployment Options**
- **Docker Compose** - Local development
- **Kubernetes** - Container orchestration
- **Cloud Ready** - AWS, Azure, GCP compatible

---

## 📚 **Documentation**

| Guide | Description |
|-------|-------------|
| [Frontend Guide](docs/FRONTEND-GUIDE.md) | Web app user manual |
| [API Testing](docs/API-TESTING.md) | REST API examples |
| [Developer Guide](README.dev.md) | Technical documentation |
| [GitHub Secrets](docs/GITHUB-SECRETS-SETUP.md) | Automated secrets management |
| [Quick Reference](docs/QUICK-REFERENCE.md) | Essential commands |

---

## 🎓 **DevOps Showcase**

This project demonstrates:
- **Modern Java Development** (Spring Boot 3.4, Java 17)
- **Frontend Engineering** (Angular 18, TypeScript)
- **Microservices Design** (Service separation, API Gateway)
- **Database Management** (PostgreSQL, Transactions, Backup)
- **Container Technology** (Docker, Kubernetes)
- **CI/CD Implementation** (GitHub Actions, Automated testing)
- **Security Implementation** (JWT, Secrets management)
- **Production Operations** (Monitoring, Health checks, Recovery)

---

## 🛠️ **Quick Commands**

```bash
# Start demo
./start-demo.sh

# View services
docker-compose ps

# Check health
curl http://localhost:8081/api/health
curl http://localhost:8082/api/health

# View logs
docker-compose logs -f

# Stop demo
docker-compose down
```

---

## 📞 **Contact**

- **GitHub:** [thanhtuanh/bankportal-demo](https://github.com/thanhtuanh/bankportal-demo)
- **Issues:** [Report bugs](https://github.com/thanhtuanh/bankportal-demo/issues)
- **License:** MIT

---

**🎯 Enterprise-grade banking platform showcasing modern development practices and production-ready architecture.**
