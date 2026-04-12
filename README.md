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

## 11. Security Dashboard Professional

### 📊 Nouveau Dashboard Professionnel

Le dashboard a été complètement modernisé avec une interface de niveau entreprise:

```bash
# Depuis la racine du projet:
cd reports/security
npx http-server -p 8099 -c-1
```

Puis acceder a: **http://localhost:8099/professional-dashboard.html**

### 📄 Nouveautés - Rapports Professionnels

✅ **Rapports PDF Executifs**
- Formatage professionnel avec sections structurées
- Résumés exécutifs avec métriques clés
- Recommandations spécifiques par service
- Téléchargeable pour présentation aux stakeholders

✅ **Insights Auto-Générés**
- Analyse automatique des résultats de scan
- Recommandations en français professionnel
- Classement par priorité (CRITICAL → LOW)
- Actions spécifiques pour chaque vulnérabilité

✅ **Historique & Archive**
- Snapshots journaliers des métriques
- Historique 30 jours
- Analyse de tendances
- Accès rapide aux rapports antérieurs

✅ **Dashboard Moderne**
- 4 onglets: Vue d'ensemble, Historique, Services, Insights
- Visualisation temps réel des vulnérabilités
- Statistiques par service
- Interface responsive (mobile-friendly)

### 📁 Structure des Rapports

```
reports/security/
├── professional-dashboard.html    # Dashboard principal moderne
├── pdf/                          # Rapports PDF professionnels
│   └── VERMEG-Security-Report-2024-01-15.pdf
├── insights/                     # Recommandations détaillées
│   └── insights-2024-01-15.html
├── archive/                      # Historique journalier
├── dependency-check-*.html       # OWASP (Java)
├── trivy-*.html                  # Trivy (Docker)
└── latest-metrics.json          # Métriques actuelles
```

### 🎯 Fonctionnalités du Dashboard

| Onglet | Contenu |
|--------|---------|
| **📊 Overview** | Statistiques en temps réel, breakdown par composant |
| **📋 History** | Rapports précédents, PDF téléchargeable, insights linkés |
| **🔧 Services** | Santé de chaque microservice, OWASP/Trivy status |
| **💡 Insights** | Recommandations auto-générées, actions prioritaires |

### 🔄 Génération Automatique

À chaque push sur `master`, le pipeline CI/CD:
1. Exécute tous les scans (OWASP, Trivy, npm audit, GitLeaks)
2. Génère les rapports PDF
3. Produit les insights avec recommandations
4. Crée des snapshots d'archive
5. Met à jour le dashboard automatiquement

### 📖 Documentation Complète

Pour voir tous les détails, configurations et bonnes pratiques:

👉 Consulter: **[SECURITY_DASHBOARD.md](SECURITY_DASHBOARD.md)**

Contient:
- Guide d'utilisation complet
- Format des rapports en détail
- Intégration CI/CD
- Personnalisation et support

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
