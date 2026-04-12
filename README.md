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
- Conteneurs: Docker Compose (stack complete)

## 3. Architecture (ports)
- Frontend (Nginx): `5173`
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
- Docker (WSL2 ou Docker Desktop)
- PowerShell (Windows) ou terminal WSL

## 5. Installation
Le frontend est dans `front/`.

Pour un lancement Docker complet, pas besoin de `npm install`.

## 6. Lancement complet (Docker Compose)
Depuis la racine du projet:

```bash
docker compose -f backend/docker-compose.yml build
docker compose -f backend/docker-compose.yml up -d
```

## 7. Initialisation des donnees (seed)
Si tu veux le lancer dans WSL :
''pwsh
pwsh -File backend/seed.ps1
Si tu veux sur windows powershell:

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
### Si Docker Desktop/localhost OK
- Application: `http://localhost:5173`
- Keycloak: `http://localhost:8080`
- Gateway health: `http://localhost:8081/actuator/health`

### Si Docker tourne uniquement dans WSL (sans Desktop)
Utiliser l’IP WSL:
```bash
hostname -I
```
Exemple:
- Application: `http://<IP_WSL>:5173`
- Keycloak: `http://<IP_WSL>:8080`
- Gateway health: `http://<IP_WSL>:8081/actuator/health`

## 10. Structure du projet
- `front/`: frontend Angular
- `backend/api-gateway`: Gateway
- `backend/employee-service`: RH employe / auth adapter
- `backend/recruitment-service`: offres, candidatures, entretiens
- `backend/approval-service`: validation manager/RH
- `backend/keycloak`: realm import
- `backend/db/seed.sql`: donnees de demonstration

## 11. Security Dashboard

### Lancer le dashboard localement

```bash
# Depuis la racine du projet:
cd reports/security
npx http-server -p 8099 -c-1
```

Puis acceder a: **http://localhost:8099** ou **http://127.0.0.1:8099**

### Dashboard Features

- 🛡️ Vue d'ensemble des vulnerabilites
- 🔎 OWASP Dependency-Check (Java + npm)
- 🐳 Trivy Image Scan (Docker images)
- 🧪 Snyk Continuous Analysis
- 📦 npm audit (Frontend)
- 🔐 GitLeaks Secret Detection

Tous les rapports sont generes automatiquement par le CI/CD a chaque push.

### Configuration

Pour activer les vrais scans OWASP:
1. Genere une clé NVD API sur https://nvd.nist.gov
2. Add dans GitHub Settings → Secrets → `NVD_API_KEY`
3. Push un commit pour declencher les scans

## 12. CI/CD & Security

- **Workflow**: `.github/workflows/ci.yml`
- **Auto-scans**: OWASP, Trivy, npm audit, Snyk, GitLeaks
- **Rapports**: generes dans `reports/security/`
- **Dashboard**: agrege tous les resultats en temps reel

Voir `SECURITY_DEVSECOPS.md` pour plus de details.

```powershell
git add .
git commit -m "Update README and project setup"
git push

 

## 12. Depannage rapide
- Backend indisponible:
  `docker compose -f backend/docker-compose.yml up -d`
- Donnees vides:
  executer `backend/seed.ps1`
- WSL sans Docker Desktop:
  utiliser l’IP WSL au lieu de `localhost`
