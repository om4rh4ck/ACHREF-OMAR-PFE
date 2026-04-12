# VERMEG Security DevSecOps

## 📋 Vue d'ensemble

Cette documentation décrit les pratiques de sécurité DevSecOps intégrées dans le pipeline CI/CD du projet VERMEG SIRH.

## 🔐 Stack de Sécurité

### 1. **OWASP Dependency-Check** 
   - **Objectif**: Détecter les dépendances avec des vulnérabilités connues
   - **Outils**: Maven plugin pour Java + npm pour le frontend
   - **Fréquence**: À chaque push
   - **NVD API**: Nécessite `NVD_API_KEY` (secret GitHub)
   - **Rapports**: `dependency-check-[service].html`

### 2. **Trivy Image Scan**
   - **Objectif**: Scanner les images Docker for OS + application vulnerabilities
   - **Couverture**: 5 services (4 backend + 1 frontend)
   - **Fréquence**: À chaque push  
   - **Rapports**: `trivy-[service].html`
   - **Severities**: CRITICAL, HIGH, MEDIUM, LOW

### 3. **npm audit**
   - **Objectif**: Détecter les vulnérabilités dans les dépendances NPM
   - **Couverture**: Frontend Angular
   - **Fréquence**: À chaque push
   - **Rapports**: `npm-audit.txt`

### 4. **Snyk Continuous Analysis**
   - **Objectif**: Analyse continue des dépendances + SAST basique
   - **Fréquence**: À chaque push (si `SNYK_TOKEN` configuré)
   - **Rapports**: `snyk-backend.txt`, `snyk-frontend.txt`
   - **Note**: Optionnel (nécessite un compte Snyk gratuit)

### 5. **GitLeaks Secret Detection**
   - **Objectif**: Empêcher les secrets/credentials d'être committés
   - **Couverture**: Tout le repo
   - **Fréquence**: À chaque push
   - **Rapports**: `gitleaks-report.txt`

## 📊 Dashboard de Sécurité

**URL**: `reports/security/index.html`

Le dashboard agrège les résultats de tous les scans en temps réel:
- Compte total des vulnérabilités par sévérité
- Liens vers les rapports détaillés
- Statut des scans (OWASP, Trivy, npm, Snyk, GitLeaks)

### Interprétation des Sévérités

| Level | Signification | Action |
|-----|---|---|
| 🔴 **CRITICAL** | Exploitation facile, impact haute | Corriger avant production |
| 🟠 **HIGH** | Exploitation probable, impact importante | Corriger rapidement |
| 🟡 **MEDIUM** | Exploitation possible, impact modéré | Planifier correction |
| 🟢 **LOW** | Exploitation difficile, impact faible | Monitorer |

## 🔧 Configuration

### GitHub Secrets Requis

```bash
# Pour OWASP Dependency-Check
NVD_API_KEY=your_nvd_api_key  # Optionnel: active l'API NVD officiel

# Pour Snyk (optionnel)
SNYK_TOKEN=your_snyk_token

# Credentials existants
SONAR_TOKEN
SONAR_PROJECT_KEY
SONAR_ORG
SONAR_HOST_URL
```

### Obtenir une clé NVD API

1. Créer un compte sur https://nvd.nist.gov
2. Générer une API key
3. Ajouter dans GitHub Settings → Secrets → `NVD_API_KEY`

### Setup Snyk Gratuit

1. S'inscrire sur https://snyk.io (gratuit)
2. Générer un API token
3. Ajouter dans GitHub Secrets → `SNYK_TOKEN`

## 🚀 Pipeline d'Exécution

Le workflow CI/CD exécute les scans dans cet ordre:

```
1. [secrets-detection] GitLeaks scan
   ↓
2. [backend-build] Maven test + build
   ↓
3. [frontend-build] npm build
   ↓
4. [sonar] SonarCloud analysis (optionnel)
   ↓
5. [security-reports]
   ├─ OWASP Dependency-Check (4 services)
   ├─ Trivy image scan (5 images)
   ├─ npm audit (frontend)
   ├─ Snyk analysis (optionnel)
   ├─ Aggregate results → Dashboard
   └─ Commit reports
```

## 📈 Amélioration Continue

### Réduire les Vulnérabilités

**Actions Immédiates**:
1. Mettre à jour les dépendances: `mvn versions:update-properties` ou `npm update`
2. Vérifier les rapports détaillés pour les CVE critiques
3. Appliquer les patches de sécurité

**À Long Terme**:
1. Utiliser des dépendances minimales
2. Surveiller les CVE nouvelles (outils comme Dependabot)
3. Implementer SBOM (Software Bill of Materials)

### Faux Positifs

Certains scans peuvent avoir des faux positifs:
- OWASP: Dépendances transitives non utilisées
- Trivy: Vulnérabilités du système d'exploitation (OS layer)
- npm: Dépendances dev non critiques

**Solution**:
- Vérifier manuellement avant de supprimer
- Documenter les exceptions dans `.suppressions` ou `.config`

## 🛡️ Best Practices

### Code
- ✅ Valve des inputs utilisateur
- ✅ Utiliser HTTPS/TLS
- ✅ Hashage des mots de passe (bcrypt, Argon2)
- ✅ CORS config stricte
- ✅ Headers de sécurité (X-Frame-Options, CSP, etc.)

### Dépendances
- ✅ Maintenir dependencies à jour
- ✅ Auditer régulièrement
- ✅ Limiter le nombre de dépendances
- ✅ Préférer les libs mainstream

### Secrets & Credentials
- ✅ Utiliser GitHub Secrets (jamais en plaintext)
- ✅ Limiter les permissions (least privilege)
- ✅ Rotation régulière des credentials
- ✅ Audit logs des accès

### Infrastructure
- ✅ Images Docker minimales (alpine)
- ✅ Pas de root dans containers
- ✅ Scans d'images avant production
- ✅ Limits de ressources (CPU, memory)

## 📚 Ressources Additionnelles

- **OWASP Top 10**: https://owasp.org/Top10/
- **NVD Database**: https://nvd.nist.gov
- **Trivy GitHub**: https://github.com/aquasecurity/trivy
- **Snyk**: https://snyk.io
- **GitLeaks**: https://github.com/gitleaks/gitleaks

## 🔄 Support & Troubleshooting

### OWASP échoue avec 403 Forbidden
→ Ajouter `NVD_API_KEY` ou attendre (rate limiting)

### Trivy scan très lent
→ Normal la première fois, utilisé du cache après

### Faux positif "secret" dans GitLeaks
→ Ajouter `# gitleaks:allow` + reviewer approve avant merge

### Snyk intégration ne marche pas
→ Vérifier `SNYK_TOKEN` valid + access du repo

## 📝 Changelog

- **v1.0** (2026-04-12): Initial setup
  - OWASP Dependency-Check
  - Trivy image scanning
  - npm audit
  - Snyk integration (optional)
  - GitLeaks secret detection
  - Unified dashboard

---

*Last updated: 2026-04-12*
**Maintainers**: DevSecOps Team
