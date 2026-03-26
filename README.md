# VERMEG SIRH

Application SIRH (PFE) avec frontend Angular standalone et backend microservices Spring Boot.

## 1. Fonctionnalites principales
- Authentification SSO via Keycloak
- Tableau de bord employe / manager / RH
- Gestion des offres internes
- Gestion des candidatures et entretiens
- Messagerie interne, actualites, notifications
- Parametrage RH (departements, types de contrat, utilisateurs)

## 2. Stack technique
- Frontend: Angular + TypeScript + Bootstrap/Material
- Backend: Spring Boot microservices
- Gateway: Spring Cloud Gateway
- Securite: Keycloak (OAuth2/OIDC)
- Base de donnees: PostgreSQL
- Conteneurs: Docker Compose (Postgres + Keycloak)

## 3. Architecture (ports)
- Frontend Angular dev server: `5173`
- Keycloak: `8080`
- API Gateway: `8081`
- Employee Service: `8082`
- Recruitment Service: `8083`
- Approval Service: `8084`
- PostgreSQL: `5432`

## 4. Prerequis
- Node.js 20+ et npm
- Java 17+
- Maven 3.9+
- Docker Desktop
- PowerShell (Windows)

## 5. Installation
Depuis la racine du projet:

```powershell
npm install
```

## 6. Lancement complet (Windows)
### Etape A - Infrastructure (Postgres + Keycloak)
```powershell
docker compose -f backend/docker-compose.yml up -d
```

### Etape B - Microservices Spring
```powershell
powershell -ExecutionPolicy Bypass -File backend/run-all.ps1
```

Option: avec infra en meme temps
```powershell
powershell -ExecutionPolicy Bypass -File backend/run-all.ps1 -StartInfra
```

### Etape C - Frontend
Dans un nouveau terminal:
```powershell
npm run dev
```

## 7. Initialisation des donnees (seed)
Une fois les services demarres au moins une fois:

```powershell
powershell -ExecutionPolicy Bypass -File backend/seed.ps1
```

## 8. Comptes de test
- `admin@vermeg.com / admin123`
- `manager@vermeg.com / manager123`
- `recruiter@vermeg.com / recruiter123`
- `employee@vermeg.com / employee123`
- `candidate@vermeg.com / candidate123` (si cree dans Keycloak/seed)

## 9. URLs utiles
- Application: `http://localhost:5173`
- Keycloak: `http://localhost:8080`
- Gateway health: `http://localhost:8081/actuator/health`

## 10. Structure du projet
- `src/`: frontend Angular
- `backend/api-gateway`: Gateway
- `backend/employee-service`: RH employe / auth adapter
- `backend/recruitment-service`: offres, candidatures, entretiens
- `backend/approval-service`: validation manager/RH
- `backend/keycloak`: realm import
- `backend/db/seed.sql`: donnees de demonstration

## 11. Partager avec ton encadreur sur Git
### Option A - Nouveau repository GitHub
1. Cree un repo vide sur GitHub (ex: `vermeg-sirh-pfe`)
2. Dans la racine du projet:

```powershell
git init
git add .
git commit -m "Initial version - VERMEG SIRH PFE"
git branch -M main
git remote add origin https://github.com/<ton-user>/<ton-repo>.git
git push -u origin main
```

### Option B - Repository deja existant
```powershell
git add .
git commit -m "Update README and project setup"
git push
```

### Conseils de partage
- Envoie a ton encadreur le lien GitHub + ce README
- Joins 3 captures: login, dashboard RH, offres internes
- Ajoute une courte video (1-2 min) montrant le lancement local

## 12. Depannage rapide
- Erreur proxy Angular `/api/... ECONNREFUSED`:
  les services `8081-8084` sont arretes, relance `backend/run-all.ps1`
- Keycloak inaccessible:
  relancer `docker compose -f backend/docker-compose.yml up -d`
- Donnees vides:
  executer `backend/seed.ps1`
