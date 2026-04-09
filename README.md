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

## 13. CI/CD (GitHub + DockerHub + Deploiement)

### 13.1 Secrets GitHub (obligatoires)
Moi, je mets **tous** ces secrets dans:
`Settings > Secrets and variables > Actions`

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `SONAR_HOST_URL` (ex: `https://sonarcloud.io`)
- `SONAR_TOKEN`
- `SONAR_ORG` (ex: `om4rh4ck`)
- `SONAR_PROJECT_KEY` (la cle exacte du projet SonarCloud)
- `DEPLOY_STRATEGY` (optionnel: `rolling` ou `blue`)

### 13.2 Mon workflow complet (avec mes mots)
Quand **moi** je fais une modif, je respecte **toujours** ces etapes:

#### Etape 1 - Je modifie le code
Je modifie les fichiers dans `front/` (frontend) ou `src/` / `backend/` (backend).

#### Etape 2 - Je commit + push (ca lance la CI)
```bash
git status
git add front src backend
git commit -m "feat: update"
git push
```
La **CI** fait:
- build backend
- build frontend
- sonar (si secrets OK)

#### Etape 3 - Je tag (ca lance le CD)
**Le CD ne se lance que sur un tag**:
```bash
git tag v1.0.10
git push origin v1.0.10
```
Le **CD** fait:
- build + push images DockerHub
- deploy automatique via runner self-hosted

#### Etape 4 - Je laisse le runner allume (obligatoire)
Le deploy utilise **mon PC** (runner self-hosted), donc je dois le laisser actif:
```bash
cd actions-runner
./run.sh
```
Je dois voir: `Listening for Jobs`.

### 13.3 Pipeline CI (automatique)
Fichier: `.github/workflows/ci.yml`
Ce workflow:
- build parallele des microservices
- build du frontend
- scan SonarCloud (si secrets OK)

### 13.4 Pipeline CD (automatique sur tag)
Fichier: `.github/workflows/cd.yml`
Ce workflow:
- se declenche sur tag `vX.Y.Z`
- build + push DockerHub
- deploy local avec runner self-hosted

### 13.5 Deploiement (Blue/Green ou Rolling)
Le dossier `deploy/` contient:
- `docker-compose.base.yml` (postgres + keycloak)
- `docker-compose.app.yml` (services)
- `docker-compose.router.yml` (nginx reverse proxy)
- `blue.env` / `green.env` (stack + tag + dockerhub user)
- `blue-green.sh` (switch automatique)
- `rolling.sh` (mise a jour directe)

#### Blue/Green manuellement
```bash
chmod +x deploy/blue-green.sh
./deploy/blue-green.sh v1.0.10
```

#### Rolling manuellement
```bash
chmod +x deploy/rolling.sh
./deploy/rolling.sh v1.0.10
```

### 13.6 Verifier les images DockerHub
Moi je verifie que les images sont bien poussees:
- `2025omar/vermeg-employee-service`
- `2025omar/vermeg-recruitment-service`
- `2025omar/vermeg-approval-service`
- `2025omar/vermeg-api-gateway`
- `2025omar/vermeg-frontend`

## 14. Securite DevSecOps (1.4)
Objectif: je fais un **scan securite complet** sur le code + images.

### 14.0 Dashboard securite (port unique)
Un dashboard est disponible sur **un seul port**:
```
http://<IP>:8099
```
Il pointe vers les vrais rapports generes par la CI (OWASP / Trivy / Snyk / npm audit).
Pour le lancer:
```bash
docker compose -f deploy/docker-compose.security.yml up -d
```

### 14.1 OWASP Dependency-Check (Java + npm)
Je l’utilise pour detecter les CVE dans les dependances.

#### Backend (Java/Maven)
```bash
cd backend/employee-service
mvn -DskipTests org.owasp:dependency-check-maven:8.4.0:check
```
Le rapport se genere dans:
`target/dependency-check-report.html`

#### Frontend (npm)
```bash
cd front
npm audit
```
Si besoin:
```bash
npm audit fix
```

### 14.2 Trivy (scan images Docker)
Je scanne chaque image que je build/push.
```bash
trivy image 2025omar/vermeg-employee-service:v1.0.10
trivy image 2025omar/vermeg-recruitment-service:v1.0.10
trivy image 2025omar/vermeg-approval-service:v1.0.10
trivy image 2025omar/vermeg-api-gateway:v1.0.10
trivy image 2025omar/vermeg-frontend:v1.0.10
```

### 14.3 Snyk (analyse continue)
Je connecte Snyk a GitHub pour avoir des alertes continues.
Et localement:
```bash
snyk auth
snyk test
```

### 14.4 Integration CI (automatique)
J’ai un job `security-reports` dans la CI qui:
- genere tous les rapports
- met a jour `reports/security/*`
- commit automatiquement les rapports

Secrets requis pour Snyk:
- `SNYK_TOKEN`
