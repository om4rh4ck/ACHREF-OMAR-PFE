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

## 6. Lancement unifie
Depuis la racine du projet, utilise une seule famille de commandes et garde les memes URLs locales dans les 2 cas:

- Frontend: `http://localhost:5173`
- Keycloak: `http://localhost:8080`
- API Gateway: `http://localhost:8081`
- PostgreSQL: `localhost:5432`

### Docker
```bash
chmod +x scripts/run-stack.sh scripts/stop-stack.sh
./scripts/run-stack.sh docker --build
```

### Kubernetes
Prerequis: cluster Kubernetes deja demarre, par exemple avec Minikube.

```bash
chmod +x scripts/run-stack.sh scripts/stop-stack.sh
./scripts/run-stack.sh k8s
```

Le mode `k8s` expose les memes ports locaux via `kubectl port-forward`, ce qui permet au frontend et a Keycloak de fonctionner avec les memes URLs que Docker.

### Arret
```bash
./scripts/stop-stack.sh docker
./scripts/stop-stack.sh k8s
```

Les donnees PostgreSQL sont conservees:
- en `docker`, le script fait `stop` et conserve les conteneurs, le volume et la base
- en `k8s`, le script met les deployments a `0` replica et conserve le `PersistentVolumeClaim` `postgres-data`

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
- Application: `http://localhost:5173`
- Keycloak: `http://localhost:8080`
- Gateway health: `http://localhost:8081/actuator/health`
- PostgreSQL: `localhost:5432`

Ces URLs sont les memes si tu lances le projet avec `docker` ou avec `k8s` via `./scripts/run-stack.sh`.


## 10. Structure du projet
- `front/`: frontend Angular
- `backend/api-gateway`: Gateway
- `backend/employee-service`: RH employe / auth adapter
- `backend/recruitment-service`: offres, candidatures, entretiens
- `backend/approval-service`: validation manager/RH
- `backend/keycloak`: realm import
- `backend/db/seed.sql`: donnees de demonstration

## 11. Security Dashboard Professional

### 📊 Dashboard Professionnel avec Interface Sidebar

Le dashboard a été complètement redessiné avec une interface moderne de niveau entreprise:

```bash
# Depuis la racine du projet:
cd reports/security
npx http-server -p 8099 -c-1
```

Puis acceder a: **http://localhost:8099/dashboard.html**

### 🎨 Fonctionnalités du Dashboard

✅ **Interface Moderne**
- Sidebar de navigation avec 6 sections
- Dark theme professionnel
- Cartes de statistiques en temps réel
- Responsive design (desktop, tablet, mobile)

✅ **Sections de Scan**
- **Overview**: Vue d'ensemble consolidée
- **OWASP**: Résultats dependency-check (Java)
- **Trivy**: Résultats image scans (Docker)
- **Snyk**: Analyse continue SCA/SAST
- **npm audit**: Dépendances frontend
- **GitLeaks**: Détection des secrets

✅ **Rapports PDF Executifs**
- Génération automatique à chaque push
- Résumés exécutifs avec métriques
- Recommandations par service
- Téléchargeable pour stakeholders

✅ **Insights Auto-Générés**
- Analyse automatique des résultats
- Recommandations French professionnelles
- Classement par priorité (CRITICAL → LOW)
- Actions spécifiques et mesurables

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
├── dashboard.html                 # Professional security dashboard
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

## 12. SAST & Gestion des Secrets

### 🔐 Security Testing (Static Application Security Testing)

Analyse statique complète du code source avec multiples outils:

**Outils intégrés:**
- **SonarQube**: Code quality & security hotspots
- **Bandit**: Python security analysis
- **Semgrep**: Semantic code analysis (OWASP Top 10)
- **ESLint**: JavaScript/TypeScript security
- **SpotBugs**: Java static analysis

**Execution manuelle:**
```bash
# Tous les SAST
python3 scripts/sast-orchestrator.py all

# Outil spécifique
python3 scripts/sast-orchestrator.py sonar
python3 scripts/sast-orchestrator.py bandit
python3 scripts/sast-orchestrator.py semgrep
python3 scripts/sast-orchestrator.py eslint
```

**Rapports générés:**
- `reports/security/sast-report-*.html` (rapport consolidé)
- `reports/security/sast-report-*.json` (données brutes)
- Détails par outil dans `reports/security/`

### 🔑 HashiCorp Vault - Gestion Centralisée des Secrets

Stockage sécurisé et rotation automatique des credentials:

**Setup (5 minutes):**
```bash
# 1. Démarrer Vault
cd infrastructure/vault
docker-compose up -d

# 2. Initialiser
bash vault-init.sh

# 3. Configurer GitHub Secrets (voir QUICK_START_SAST_SECRETS.md)
```

**Secrets gérés:**
- 🔐 Credentials base de données (PostgreSQL)
- 🔐 API tokens (Snyk, SonarQube, NVD)
- 🔐 OAuth tokens (GitHub, DockerHub)
- 🔐 SSH keys (déploiement)

**Rotation automatique:**
```bash
# Check credentials expirant dans 30 jours
python3 scripts/vault-secrets-manager.py check-expiry

# Rotation complète (tous les 90 jours)
python3 scripts/vault-secrets-manager.py rotate-all

# Sync vers GitHub Secrets
python3 scripts/vault-secrets-manager.py sync-github
```

**Architecture:**
```
┌─────────────────────┐
│  HashiCorp Vault    │
│  (Secrets Storage)  │
└─────────┬───────────┘
          │
      ┌───┴─────────────┬─────────────┐
      ▼                 ▼             ▼
  CI/CD Pipeline    Applications   Monitoring
```

**Documentation complète:**
👉 [SAST-AND-SECRETS-GUIDE.md](docs/SAST-AND-SECRETS-GUIDE.md)
👉 [QUICK_START_SAST_SECRETS.md](QUICK_START_SAST_SECRETS.md)
👉 [CI_CD_ENHANCEMENT.md](docs/CI_CD_ENHANCEMENT.md)

## 13. CI/CD & Security

- **Workflow**: `.github/workflows/ci.yml`
- **SAST Scans**: SonarQube, Bandit, Semgrep, SpotBugs, ESLint
- **Dependency Checks**: OWASP, Trivy, npm audit, Snyk
- **Secret Detection**: GitLeaks
- **Secret Management**: HashiCorp Vault + GitHub Secrets
- **Automated Rotation**: Credentials rotated based on policy
- **Rapports**: Générés dans `reports/security/`
- **Dashboard**: Agrège tous les résultats en temps réel

Voir `SAST-AND-SECRETS-GUIDE.md` pour plus de détails.

```powershell
git add .
git commit -m "Update README and project setup"
git push

 

## 14. Depannage rapide

**Backend indisponible:**
```bash
docker compose -f backend/docker-compose.yml up -d
```

**Donnees vides:**
```powershell
powershell -ExecutionPolicy Bypass -File backend/seed.ps1
```

**WSL sans Docker Desktop:**
Utiliser l'IP WSL au lieu de `localhost`:
```bash
hostname -I
```

**Vault ne démarre pas:**
```bash
cd infrastructure/vault
docker-compose down -v
docker-compose up -d
sleep 10
bash vault-init.sh
```

**SAST tools manquants:**
```bash
pip install -r requirements-security.txt
```

---

## 📚 Documentation Complète

| Document | Contenu |
|----------|---------|
| [SAST-AND-SECRETS-GUIDE.md](docs/SAST-AND-SECRETS-GUIDE.md) | Guide complet SAST & Vault |
| [QUICK_START_SAST_SECRETS.md](QUICK_START_SAST_SECRETS.md) | Setup rapide (5 min) |
| [SECURITY_DASHBOARD.md](SECURITY_DASHBOARD.md) | Dashboard sécurité professionnel |
| [CI_CD_ENHANCEMENT.md](docs/CI_CD_ENHANCEMENT.md) | Intégration CI/CD avancée |
| [API_MAP.md](backend/API_MAP.md) | Mapping des endpoints API |

---

## ✅ Checklist Déploiement

- [ ] Backend Docker running (`docker compose up -d`)
- [ ] Database seeded (`backend/seed.ps1`)
- [ ] Frontend accessible (`http://localhost:5173`)
- [ ] Keycloak running (`http://localhost:8080`)
- [ ] Vault initialized (`infrastructure/vault/vault-init.sh`)
- [ ] SAST configured (`scripts/sast-orchestrator.py all`)
- [ ] GitHub Secrets configured (VAULT_ADDR, VAULT_TOKEN, etc)
- [ ] Test credentials rotation (`vault-secrets-manager.py check-expiry`)

---

## 📞 Support

Pour des questions ou problèmes:

1. Consulter la documentation appropriée (liens ci-dessus)
2. Vérifier les logs: `docker logs <container-name>`
3. Vérifier l'état des services: `http://localhost:8081/actuator/health`
4. Créer une issue GitHub avec logs et contexte

---

**Version:** 2.0.0 (with SAST & Vault)  
**Last Updated:** January 2024
**Stack Quality:** ⭐⭐⭐⭐⭐ Enterprise-Grade

