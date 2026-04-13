# SAST et Gestion des Secrets - Guide d'Implémentation Complet

## Table des matières
1. [Vue d'ensemble](#vue-densemble)
2. [Gestion des Secrets](#gestion-des-secrets)
3. [SAST (Static Application Security Testing)](#sast)
4. [Configuration CI/CD](#configuration-cicd)
5. [Rotation des Credentials](#rotation-des-credentials)
6. [Best Practices](#best-practices)

---

## Vue d'ensemble

Ce document décrit l'implémentation complète d'un système de sécurité robuste pour VERMEG SIRH:

### Architecture Sécurisée

```
┌─────────────────────────────────────────────────────┐
│              Secrets Management                      │
├─────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐               │
│  │ GitHub       │    │ HashiCorp    │               │
│  │ Secrets      │◄──►│ Vault        │               │
│  └──────────────┘    └──────────────┘               │
│       ▲                     ▲                         │
│       │                     │                         │
│  Sync │          Rotation   │ Retrieval               │
│       │                     │                         │
└───────┼─────────────────────┼─────────────────────────┘
        │                     │
        │                     │
┌───────▼─────────────────────▼─────────────────────────┐
│              CI/CD Pipeline                           │
├─────────────────────────────────────────────────────┤
│  • Secret Retrieval from Vault                       │
│  • Build with Secured Credentials                    │
│  • SAST Scanning                                     │
│  • Dependency Analysis                               │
│  • Secure Deployment                                 │
└─────────────────────────────────────────────────────┘
```

---

## Gestion des Secrets

### 1. HashiCorp Vault Configuration

#### Installation

**Docker**
```bash
docker-compose -f infrastructure/vault/docker-compose.yml up -d
```

**Native Installation**
```bash
# Linux/macOS
wget https://releases.hashicorp.com/vault/1.16.0/vault_1.16.0_linux_amd64.zip
unzip vault_1.16.0_linux_amd64.zip
sudo mv vault /usr/local/bin/

# macOS using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/vault
```

#### Initialisation Vault

```bash
# 1. Démarrer le serveur Vault
vault server -config=infrastructure/vault/vault-config.hcl

# 2. Dans un nouveau terminal, initialiser Vault
export VAULT_ADDR='http://127.0.0.1:8200'
bash infrastructure/vault/vault-init.sh

# 3. Unseal Vault avec les clés fournies
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>
```

#### Structure des Secrets dans Vault

```
secret/
├── cicd/
│   ├── database          # Credentials PostgreSQL
│   ├── api-keys          # Tokens: Sonar, Snyk, NVD
│   ├── oauth             # GitHub, DockerHub tokens
│   └── ssh               # SSH keys for deployment
└── application/
    ├── db-application_user
    ├── db-ci_user
    └── db-readonly_user
```

### 2. GitHub Secrets Integration

#### Configuration

**Secrets Required:**
```
- VAULT_ADDR           # Vault server address
- VAULT_TOKEN          # Vault authentication token
- VAULT_ROLE_ID        # AppRole role-id
- VAULT_SECRET_ID      # AppRole secret-id
- GITHUB_TOKEN         # GitHub PAT for secrets API
```

**Ajouter les secrets:**
```bash
# Via GitHub UI: Settings > Secrets and variables > Actions

# Via GitHub CLI
gh secret set VAULT_ADDR --body "http://vault.example.com:8200"
gh secret set VAULT_TOKEN --body "s.xxxxxxxxxxxxx"
gh secret set VAULT_ROLE_ID --body "role-id-xxxxx"
gh secret set VAULT_SECRET_ID --body "secret-id-xxxxx"
```

#### Synchronisation Vault → GitHub

```bash
# Synchroniser les secrets de Vault vers GitHub
export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='<your-token>'
export GITHUB_TOKEN='<github-token>'
export GITHUB_REPO='om4rh4ck/ACHREF-OMAR-PFE'

python3 scripts/vault-secrets-manager.py sync-github
```

### 3. Retrieval des Secrets en Runtime

#### Dans les Applications Java

**application.yml Configuration:**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:vermeg_sirh}
    username: ${DB_USER:postgres}
    password: ${DB_PASSWORD:}
  
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: ${KEYCLOAK_ISSUER_URI:http://localhost:8080/realms/vermeg-sirh}

management:
  endpoints:
    web:
      exposure:
        include: health,info
```

**Runtime Secret Injection:**
```bash
# Via environment variables (Docker)
docker run \
  -e DB_HOST=postgres \
  -e DB_USER=vault_user \
  -e DB_PASSWORD=$(vault kv get -field=password secret/cicd/database) \
  vermeg-app:latest
```

#### Dans le Frontend Angular

**environment.ts:**
```typescript
export const environment = {
  production: false,
  apiUrl: process.env['API_URL'] || 'http://localhost:8081',
  keycloakUrl: process.env['KEYCLOAK_URL'] || 'http://localhost:8080',
  appName: 'VERMEG SIRH'
};
```

**runtime-config.json (Généré à deployment):**
```bash
# Cette configuration est injectée à runtime, pas embedée
cat > front/dist/runtime-config.json <<EOF
{
  "apiUrl": "${API_URL}",
  "keycloakUrl": "${KEYCLOAK_URL}",
  "apiKey": "${API_KEY}"
}
EOF
```

---

## SAST (Static Application Security Testing)

### 1. SonarQube Integration

#### Installation et Configuration

**Docker Compose:**
```bash
# Ajouter à docker-compose.yml
sonarqube:
  image: sonarqube:9.9-community
  ports:
    - "9000:9000"
  environment:
    SONAR_JDBC_URL: jdbc:postgresql://postgres:5432/sonarqube
    SONAR_JDBC_USERNAME: sonar
    SONAR_JDBC_PASSWORD: sonar
  depends_on:
    - postgres

# Démarrer
docker-compose up -d sonarqube
```

**Initial Setup:**
- Accéder à http://localhost:9000 avec admin/admin
- Changer le mot de passe
- Créer le projet "vermeg-sirh"
- Générer le token d'authentification

#### Configuration CI/CD

```yaml
sonar:
  runs-on: ubuntu-latest
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_PROJECT_KEY: ${{ secrets.SONAR_PROJECT_KEY }}
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
  steps:
    - name: SonarCloud scan
      uses: SonarSource/sonarcloud-github-action@v2
      env:
        SONAR_TOKEN: ${{ env.SONAR_TOKEN }}
      with:
        args: >
          -Dsonar.projectKey=${{ env.SONAR_PROJECT_KEY }}
          -Dsonar.sources=backend,front
          -Dsonar.java.binaries=backend/*/target/classes
```

### 2. Bandit - Python Security Scanner

```bash
# Installation
pip install bandit

# Exécution
bandit -r scripts/ -f json -o bandit-report.json

# Avec configuration
bandit -r scripts/ -c .bandit -f json
```

**.bandit Configuration:**
```yaml
assert_used:
  skips: []
test_sql_injection:
  skips: []
blacklist_calls:
  skips: []
```

### 3. Semgrep - Semantic Code Analysis

```bash
# Installation
curl -sSL https://raw.githubusercontent.com/returntocorp/semgrep/develop/install-ubuntu.sh | bash

# Exécution
semgrep --config=p/security-audit --config=p/owasp-top-ten -r backend,front

# Avec rapport
semgrep --config=p/security-audit -r . --json -o semgrep-report.json
```

**Rules Incluses:**
- OWASP Top 10 vulnerabilities
- CWE-89: SQL Injection
- CWE-79: Cross-site Scripting
- CWE-287: Improper Authentication
- CWE-434: File Upload Validation

### 4. SpotBugs - Java Static Analysis

```bash
# Installation
brew install spotbugs  # macOS
# ou télécharger depuis https://spotbugs.readthedocs.io/

# Exécution
spotbugs -html -output spotbugs-report.html backend/*/target/classes
```

### 5. ESLint Security Plugin

**Installation:**
```bash
cd front
npm install --save-dev eslint-plugin-security

# Configuration .eslintrc.json
{
  "plugins": ["security"],
  "extends": ["eslint:recommended", "plugin:security/recommended"]
}

# Exécution
npm run lint
```

### 6. Orchestration Complète

**Lancer tous les SAST:**
```bash
python3 scripts/sast-orchestrator.py all
```

**Exécuter un outil spécifique:**
```bash
python3 scripts/sast-orchestrator.py sonar    # SonarQube
python3 scripts/sast-orchestrator.py bandit   # Bandit
python3 scripts/sast-orchestrator.py semgrep  # Semgrep
python3 scripts/sast-orchestrator.py eslint   # ESLint
```

---

## Configuration CI/CD

### Enhanced CI/CD Workflow avec Secrets et SAST

```yaml
name: secure-ci

on:
  push:
    branches: ["master", "develop"]
  pull_request:

jobs:
  # 1. Secret Management
  secrets-setup:
    runs-on: ubuntu-latest
    steps:
      - name: Retrieve secrets from Vault
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ secrets.VAULT_ADDR }}
          method: approle
          roleId: ${{ secrets.VAULT_ROLE_ID }}
          secretId: ${{ secrets.VAULT_SECRET_ID }}
          secrets: |
            cicd/database username | DB_USER ;
            cicd/database password | DB_PASSWORD ;
            cicd/api-keys sonar_token | SONAR_TOKEN ;
            cicd/api-keys snyk_token | SNYK_TOKEN ;
            cicd/api-keys nvd_api_key | NVD_API_KEY

  # 2. SAST Scanning
  sast-scan:
    needs: secrets-setup
    runs-on: ubuntu-latest
    env:
      SONAR_TOKEN: ${{ needs.secrets-setup.outputs.SONAR_TOKEN }}
      SONAR_HOST_URL: http://sonarqube:9000
      SONAR_PROJECT_KEY: vermeg-sirh
    services:
      sonarqube:
        image: sonarqube:9.9-community
        options: >-
          --health-cmd "curl -f http://localhost:9000/api/system/health || exit 1"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "21"

      - name: Run SonarQube scan
        run: |
          cd backend/api-gateway
          mvn -q org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
            -Dsonar.projectKey=vermeg-sirh \
            -Dsonar.host.url=${{ env.SONAR_HOST_URL }} \
            -Dsonar.login=${{ env.SONAR_TOKEN }}

      - name: Run Bandit Python security scan
        run: |
          pip install bandit
          bandit -r scripts/ -f json -o reports/security/bandit-report.json

      - name: Run Semgrep analysis
        run: |
          pip install semgrep
          semgrep --config=p/security-audit -r backend,front \
            --json -o reports/security/semgrep-report.json || true

  # 3. Dependency Analysis
  dependency-check:
    runs-on: ubuntu-latest
    env:
      NVD_API_KEY: ${{ secrets.NVD_API_KEY }}
    steps:
      - name: OWASP Dependency-Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'VERMEG-SIRH'
          path: '.'
          format: 'JSON'
          args: >
            --enableExperimental

  # 4. Build with Secured Config
  secure-build:
    needs: [sast-scan, dependency-check]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Retrieve credentials
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ secrets.VAULT_ADDR }}
          method: approle
          roleId: ${{ secrets.VAULT_ROLE_ID }}
          secretId: ${{ secrets.VAULT_SECRET_ID }}
          secrets: |
            cicd/oauth dockerhub_username | DOCKER_USERNAME ;
            cicd/oauth dockerhub_password | DOCKER_PASSWORD

      - name: Build and push Docker images
        run: |
          echo ${{ env.DOCKER_PASSWORD }} | docker login -u ${{ env.DOCKER_USERNAME }} --password-stdin
          # Build and push images...
          docker logout

  # 5. Credential Rotation Check
  rotation-check:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Check expiring credentials
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ secrets.VAULT_ADDR }}
          method: approle
          roleId: ${{ secrets.VAULT_ROLE_ID }}
          secretId: ${{ secrets.VAULT_SECRET_ID }}

      - name: Python credential check
        run: |
          python3 scripts/vault-secrets-manager.py check-expiry

      - name: Notify if credentials expiring
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '⚠️ **Credentials Expiring Soon**\n\nRun credential rotation immediately!'
            })
```

---

## Rotation des Credentials

### 1. Configuration Automatique

**Planifier la rotation mensuelle:**

```yaml
# .github/workflows/rotate-credentials.yml
name: Credential Rotation

on:
  schedule:
    - cron: '0 2 1 * *'  # 1er du mois à 2h du matin

jobs:
  rotate-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Authenticate with Vault
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ secrets.VAULT_ADDR }}
          method: approle
          roleId: ${{ secrets.VAULT_ROLE_ID }}
          secretId: ${{ secrets.VAULT_SECRET_ID }}

      - name: Rotate API Keys
        run: |
          python3 scripts/vault-secrets-manager.py rotate-all

      - name: Rotate Database Passwords
        run: |
          python3 scripts/vault-secrets-manager.py rotate-db

      - name: Sync to GitHub Secrets
        run: |
          export GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }}
          export GITHUB_REPO=${{ github.repository }}
          python3 scripts/vault-secrets-manager.py sync-github

      - name: Create rotation report
        if: always()
        run: |
          cat > rotation-report.md <<EOF
          # Credential Rotation Report
          Date: $(date)
          Status: Completed
          
          ## Rotated Items
          - API Keys (Snyk, Sonar, NVD)
          - Database Passwords
          - SSH Keys
          
          ## Next Rotation: $(date -d '+30 days' '+%Y-%m-%d')
          EOF

      - name: Upload rotation report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: rotation-report
          path: rotation-report.md
```

### 2. Commandes de Rotation Manuelle

```bash
# Rotation complète
python3 scripts/vault-secrets-manager.py rotate-all

# Rotation ciblée
python3 scripts/vault-secrets-manager.py rotate-db
python3 scripts/vault-secrets-manager.py rotate-api snyk
python3 scripts/vault-secrets-manager.py rotate-ssh production

# Vérifier les credentials expirant
python3 scripts/vault-secrets-manager.py check-expiry

# Synchroniser vers GitHub
python3 scripts/vault-secrets-manager.py sync-github
```

### 3. Rotation par Service

**Base de Données:**
```sql
-- PostgreSQL password rotation
ALTER USER vault_user WITH PASSWORD 'new_secure_password';
ALTER USER application_user WITH PASSWORD 'new_password';
ALTER USER ci_user WITH PASSWORD 'new_password';

-- Verify
\du
```

**API Keys:**
- **Snyk**: https://app.snyk.io/account/settings/api
- **SonarQube**: Administration > Security > Tokens
- **NVD**: Regénérer via NIST NVD

---

## Best Practices

### 🔐 Secret Management

1. **Never commit secrets** - Utiliser `.gitignore`
2. **Use environment variables** - Ne pas hardcoder
3. **Rotate regularly** - Au minimum tous les 90 jours
4. **Audit access** - Vérifier qui accède aux secrets
5. **Encrypt in transit** - HTTPS/TLS toujours
6. **Encryption at rest** - Vault/AWS Secrets Manager

### 🛡️ SAST Best Practices

1. **Scan on every commit** - Intégration CI/CD obligatoire
2. **Fix critical issues** - 24h SLA
3. **Fix high issues** - 1 semaine SLA
4. **Track medium issues** - Sprint suivant
5. **Code review** - Valider les fixes securité
6. **Training** - Sensibilisation développeurs

### 📋 Policy Examples

**Secret Access Policy (Vault):**
```hcl
path "secret/data/cicd/*" {
  capabilities = ["read", "list"]
  
  # TTL limité
  token_ttl = "1h"
  token_max_ttl = "4h"
}

path "secret/data/cicd/*" {
  capabilities = ["read", "list"]
  
  # Restreindre par IP
  allowed_ip_addresses = ["10.0.0.0/8"]
}
```

**Security Policy (GitHub):**
```yaml
# .github/security.yml
security-and-analysis:
  secret_scanning:
    status: enabled
  secret_scanning_push_protection:
    status: enabled
  dependabot_security_updates:
    status: enabled
  dependabot_version_updates:
    status: enabled
```

---

## Monitoring et Alertes

### Vault Monitoring

```bash
# Status check
vault status

# Audit log
vault audit list
tail -f /var/log/vault-audit.log

# Health endpoint
curl http://localhost:8200/v1/sys/health | jq

# Metrics (Prometheus)
curl http://localhost:8200/v1/sys/metrics
```

### SAST Scanning

```bash
# Générer un rapport quotidien
5 2 * * * cd /opt/vermeg && python3 scripts/sast-orchestrator.py all >> /var/log/sast-daily.log 2>&1

# Envoyer les résultats
0 6 * * * curl -X POST https://security-dashboard.example.com/api/reports/latest
```

### Credential Rotation Monitoring

```bash
# Vérifier les credentials expirant dans 7 jours
0 9 * * * python3 scripts/vault-secrets-manager.py check-expiry | mail -s "Credentials expiring in 7 days" security@vermeg.com
```

---

## Troubleshooting

### Vault Issues

**Problème:** Vault sealed
```bash
# Solution: Unseal with any 3 keys
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>
```

**Problème:** AppRole auth fails
```bash
# Vérifier que AppRole est activé
vault auth list | grep approle

# Regénérer secret-id
vault write -f auth/approle/role/cicd-role/secret-id
```

### SAST Issues

**SonarQube timeout:**
```bash
# Augmenter les ressources
-Xmx2g -Xms512m
```

**Bandit warnings:**
```bash
# Ignorer les faux positifs
bandit -r scripts -s B101  # Skip assert_used
```

---

## Ressources

- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [GitHub Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [OWASP SAST Tools](https://owasp.org/www-community/Source_Code_Analysis_Tools)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Bandit Documentation](https://bandit.readthedocs.io/)
- [Semgrep Rules](https://semgrep.dev/r)

---

**Dernière mise à jour:** 2024
**Auteur:** VERMEG Security Team
**Version:** 1.0.0
