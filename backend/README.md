# VERMEG SIRH - Microservices Backend

This folder contains a Spring Boot microservices backend designed to keep the existing frontend UX while replacing the current Node/SQLite monolith.

## Services
- `api-gateway` (port 8081)
- `employee-service` (port 8082)
- `recruitment-service` (port 8083)
- `approval-service` (port 8084)
- `keycloak` (port 8080)
- `postgres` (port 5432)

## Run infrastructure
```bash
docker compose -f backend/docker-compose.yml up -d
```

## Seed database (demo data)
After services have created tables at least once:

```powershell
powershell -ExecutionPolicy Bypass -File backend/seed.ps1
```

This seeds:
- users (admin/manager/recruiter/employee/candidate)
- departments
- contract types
- news
- job offers
- sample candidate application
- employee notification

## Run services (example)
```bash
cd backend/employee-service
mvn spring-boot:run
```

## Keycloak
Realm: `vermeg-sirh`
Client ID: `sirh-frontend`
Public client for SPA usage.
