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

### Commandes de demarrage (Windows + WSL)
1. Ouvrir WSL Ubuntu (depuis PowerShell):
```powershell
wsl -d Ubuntu
```

2. Aller au projet:
```bash
cd /mnt/c/Users/TNLT1670/Downloads/projet/SIRH-PFE-VERMEG-main-main
```

3. Lancer les conteneurs:
```bash
docker compose -f backend/docker-compose.yml up -d
```

4. Verifier l'etat:
```bash
docker compose -f backend/docker-compose.yml ps
```

5. Arreter:
```bash
docker compose -f backend/docker-compose.yml down
```

## 7. Initialisation des donnees (seed)
Si tu veux des donnees demo (offres, users, etc.):

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
- Backend indisponible:
  `docker compose -f backend/docker-compose.yml up -d`
- Donnees vides:
  executer `backend/seed.ps1`
- WSL sans Docker Desktop:
  utiliser l’IP WSL au lieu de `localhost`

## 13. CI/CD (GitHub + DockerHub + Blue/Green)

### Secrets GitHub a creer
Dans `Settings > Secrets and variables > Actions`:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `SONAR_HOST_URL` (optionnel)
- `SONAR_TOKEN` (optionnel)
- `SSH_HOST` (optionnel)
- `SSH_USER` (optionnel)
- `SSH_KEY` (optionnel)
- `DEPLOY_PATH` (optionnel, ex: `/opt/vermeg`)
- `DEPLOY_STRATEGY` (optionnel: `blue` par defaut, ou `rolling`)

### Pipeline CI
Fichier: `.github/workflows/ci.yml`
- Build parallele des microservices
- Build du frontend
- Scan SonarQube (si secrets presentes)

### Pipeline CD
Fichier: `.github/workflows/cd.yml`
- Trigger sur tag `vX.Y.Z`
- Build & push images DockerHub
- Deploy via SSH (optionnel)
  - Strategie `blue` (Blue/Green) par defaut
  - Strategie `rolling` si `DEPLOY_STRATEGY=rolling`

### Blue/Green (Docker Compose)
Le dossier `deploy/` contient:
- `docker-compose.base.yml` (postgres + keycloak)
- `docker-compose.app.yml` (services applicatifs)
- `docker-compose.router.yml` (nginx reverse proxy)
- `blue.env` / `green.env` (stack + tag + dockerhub user)
- `blue-green.sh` (switch automatique)

#### Deploiement manuel (serveur)
```bash
chmod +x deploy/blue-green.sh
./deploy/blue-green.sh v1.0.0
```

#### Deploiement manuel (rolling)
```bash
chmod +x deploy/rolling.sh
./deploy/rolling.sh v1.0.0
```

### Versioning semantique (tag)
```bash
git tag v1.0.0
git push origin v1.0.0
```
