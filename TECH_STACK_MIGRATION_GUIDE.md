# Enterprise Tech Stack Migration Guide

This document outlines the architecture, setup instructions, and operational workflows for the **Expert Consultation Platform** migrated to the requested enterprise stack.

---

## 🏗️ Target Architecture Overview

| Layer | Technology | Details |
|---|---|---|
| **Customer App** | Flutter + Dart (`expert-customer`) | 1-on-1 Audio/Video consulting, wallet, Razorpay checkout |
| **Creator App** | Flutter + Dart (`expert-professional`) | Incoming call alerts, Agora RTC, earnings, KYC submission |
| **Admin Dashboard** | React 18 + TypeScript + Tailwind (`expert-admin-dashboard`) | Glassmorphism UI, KYC verification queue, call audit, Prometheus metrics |
| **Backend API** | Java 17 + Spring Boot 3.2.4 (`expert-backend-spring`) | Spring Security (JWT), Data JPA, WebSocket real-time signaling, OpenAPI / Swagger |
| **Database & Cache**| PostgreSQL 15 + Redis 7 + Flyway | Relational DDL migrations (`V1__initial_schema.sql`), distributed caching |
| **Calling** | Agora RTC SDK (Java backend token service) | Dynamic token generation with SHA256 HMAC and role validation |
| **Payments** | Razorpay / Cashfree | Order generation, HmacSHA256 client signature verification, secure webhooks |
| **Notifications & Storage** | Firebase Cloud Messaging (FCM) & AWS S3 | Push alerts for ringing calls, S3 bucket storage for KYC docs & avatars |
| **DevOps & Cloud** | Docker, Kubernetes (AWS EKS), Amazon ECR | Multi-stage Dockerfiles, Helm/K8s manifests, ALB ingress |
| **CI/CD** | GitHub Actions | Automated Maven JUnit tests, React build, and ECR container publishing |
| **Testing & Observability** | JUnit 5, Mockito, JMeter, Prometheus, Grafana | Actuator `/actuator/prometheus`, 500-user JMeter load plan |

---

## 📁 Repository Directory Structure

```text
c:\ExpertApp\
├── expert-backend/                # [NEW] Java 17 + Spring Boot 3 Backend
│   ├── pom.xml                    # Maven dependencies (Security, JPA, Redis, Agora, Razorpay)
│   ├── Dockerfile                 # Multi-stage Eclipse Temurin JRE 17 container
│   ├── src/main/java/com/expertapp/backend/
│   │   ├── config/                # SecurityConfig, JwtTokenProvider, RedisConfig, WebSocketConfig, OpenApiConfig
│   │   ├── entity/                # User, ExpertProfile, CallSession, Transaction, KycVerification, Review
│   │   ├── repository/            # Spring Data JPA repositories
│   │   ├── dto/                   # Auth, CallSession, DashboardStats, Payments
│   │   ├── service/               # AuthService, CallService, AgoraService, PaymentService, NotificationService, AdminService
│   │   ├── controller/            # AuthController, CallController, PaymentController, AdminController, ExpertController
│   │   ├── websocket/             # CallSignalingWebSocketHandler (/ws/calls)
│   │   └── exception/             # GlobalExceptionHandler
│   ├── src/main/resources/
│   │   ├── application.yml        # Enterprise properties, profiles, database connection
│   │   └── db/migration/          # Flyway V1__initial_schema.sql
│   └── src/test/java/             # JUnit 5 & Mockito test suites (AuthServiceTest, PaymentServiceTest)
│
├── expert-admin/                  # [NEW] React.js + TypeScript + Tailwind CSS Admin Console
│   ├── package.json               # React 18, Vite 5, Tailwind CSS 3, Lucide icons
│   ├── Dockerfile & nginx.conf    # Multi-stage production Nginx container
│   └── src/
│       ├── components/            # Sidebar, Header, StatsCard
│       └── views/                 # Overview, KycQueue, LiveCalls, Financials, UsersList, SystemHealth
│
├── expert-customer/               # Flutter Customer Mobile App
├── expert-professional/           # Flutter Creator Mobile App
├── archive/                       # Archived old Node.js & old Flutter admin projects
│
├── k8s/                           # [NEW] Kubernetes AWS EKS Manifests
│   ├── namespace.yaml & configmap.yaml
│   ├── backend-deployment.yaml & backend-service.yaml
│   ├── admin-deployment.yaml & admin-service.yaml
│   └── ingress.yaml (AWS ALB)
│
├── .github/workflows/             # [NEW] GitHub Actions CI/CD
│   ├── backend-ci.yml             # Maven build, JUnit 5 test, Docker build & push to ECR, EKS rollout
│   └── admin-ci.yml               # React build, Docker build & push to ECR
│
├── monitoring/                    # [NEW] Prometheus scrape configuration
│   └── prometheus.yml
│
├── testing/                       # [NEW] Postman Collection & JMeter Load Test Plan
│   ├── ExpertApp_Postman_Collection.json
│   └── expert-consultation-loadtest.jmx
│
└── docker-compose.yml             # [NEW] Local 1-command development stack
```

---

## 🚀 Running the Full Stack Locally

### Option A: 1-Command Local Stack with Docker Compose
Run all services together (PostgreSQL, Redis, Spring Boot Backend, React Admin Dashboard, Prometheus, and Grafana):
```bash
docker compose up --build
```
- **React Admin Dashboard**: `http://localhost:3000`
- **Spring Boot REST & Swagger UI**: `http://localhost:8080/swagger-ui/index.html`
- **Prometheus Metrics**: `http://localhost:9090`
- **Grafana Dashboards**: `http://localhost:3001` (user: `admin`, pass: `admin`)

---

### Option B: Running Independently for Development

#### 1. Start the Java Spring Boot Backend:
```powershell
cd c:\ExpertApp\expert-backend
& "C:\Program Files\maven\apache-maven-3.9.12\bin\mvn.cmd" spring-boot:run
```
Run JUnit 5 & Mockito tests:
```powershell
& "C:\Program Files\maven\apache-maven-3.9.12\bin\mvn.cmd" test
```

#### 2. Start the React + TypeScript + Tailwind Admin Dashboard:
```powershell
cd c:\ExpertApp\expert-admin
npm run dev
```
Open `http://localhost:3000` in your browser.

---

## 📱 Connecting the Flutter Mobile Apps

In both `expert-customer` and `expert-professional`:
1. **Base URL**: Point API client to `http://<your-machine-ip>:8080/api/v1`.
2. **WebSocket Signaling**: Connect client to `ws://<your-machine-ip>:8080/ws/calls` with `{ "event": "REGISTER", "userId": "<user-uuid>" }`.
3. **Agora Video Calls**:
   - Customer calls `/api/v1/calls/initiate` to receive `agoraChannelName` and `agoraToken`.
   - Creator receives WebSocket/FCM incoming alert and calls `/api/v1/calls/{callId}/accept` to obtain their publisher token.
   - Both devices join channel using the Agora RTC Flutter SDK (`agora_rtc_engine`).
