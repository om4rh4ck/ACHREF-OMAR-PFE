# 🔐 Quick Start - SAST & Secret Management

## 5-Minute Setup

### Prerequisites
- Docker & Docker Compose
- Python 3.11+
- Git

### Step 1: Start Vault (2 min)

```bash
# Navigate to Vault directory
cd infrastructure/vault

# Start Vault container
docker-compose up -d

# Wait for Vault to start
sleep 5

# Run initialization script
bash vault-init.sh

# Save the output somewhere secure!
# You need at least 3 unseal keys to operate Vault
```

### Step 2: Configure GitHub Secrets (2 min)

Go to your GitHub repository → Settings → Secrets and Variables → Actions

Add these secrets:
```
VAULT_ADDR=http://vault.example.com:8200
VAULT_TOKEN=<from vault-init output>
VAULT_ROLE_ID=<from vault-init output>
VAULT_SECRET_ID=<regenerate from vault>
GITHUB_TOKEN=<your GitHub PAT>
```

### Step 3: Update Application Secrets (1 min)

```bash
# Retrieve and update database credentials
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=<your-token>

# Check what's stored
python3 ../scripts/vault-secrets-manager.py list

# Update a secret
curl -X POST http://localhost:8200/v1/secret/data/cicd/database \
  -H "X-Vault-Token: $VAULT_TOKEN" \
  -d '{
    "data": {
      "username": "actual_db_user",
      "password": "actual_db_password",
      "host": "postgres.prod",
      "port": "5432",
      "database": "vermeg_sirh"
    }
  }'
```

---

## Running SAST Scans

### All Scans
```bash
python3 scripts/sast-orchestrator.py all
```

### Individual Tools
```bash
# SonarQube
python3 scripts/sast-orchestrator.py sonar

# Bandit (Python)
python3 scripts/sast-orchestrator.py bandit

# Semgrep
python3 scripts/sast-orchestrator.py semgrep

# ESLint
python3 scripts/sast-orchestrator.py eslint

# SpotBugs (Java)
python3 scripts/sast-orchestrator.py spotbugs
```

### View Reports
```bash
# HTML report
open reports/security/sast-report-*.html

# JSON report
cat reports/security/sast-report-*.json | jq
```

---

## Credential Rotation

### Check Expiring Credentials
```bash
python3 scripts/vault-secrets-manager.py check-expiry
```

### Rotate All Credentials
```bash
python3 scripts/vault-secrets-manager.py rotate-all
```

### Rotate Specific Type
```bash
python3 scripts/vault-secrets-manager.py rotate-db     # Database passwords
python3 scripts/vault-secrets-manager.py rotate-api snyk  # API keys
```

### Sync to GitHub Secrets
```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_REPO=owner/repo

python3 scripts/vault-secrets-manager.py sync-github
```

---

## Troubleshooting

### Vault Won't Start
```bash
# Check logs
docker logs vault

# Try resetting
docker-compose down -v
docker-compose up -d

# Wait 10 seconds
sleep 10
bash vault-init.sh
```

### SAST Tools Not Found
```bash
# Install missing tools
pip install -r requirements-security.txt

# For SonarQube
brew install sonar-scanner

# For Bandit
pip install bandit

# For Semgrep
curl -sSL https://raw.githubusercontent.com/returntocorp/semgrep/develop/install-ubuntu.sh | bash
```

### Secret Retrieval Fails
```bash
# Verify Vault is unsealed
curl http://localhost:8200/v1/sys/health

# Re-authenticate
export VAULT_ADDR=http://localhost:8200
vault login <token>

# Check AppRole
vault auth list
vault read auth/approle/role/cicd-role
```

---

## Common Commands Reference

| Task | Command |
|------|---------|
| Start Vault | `docker-compose -f infrastructure/vault/docker-compose.yml up -d` |
| Initialize Vault | `bash infrastructure/vault/vault-init.sh` |
| Unseal Vault | `vault operator unseal <key>` (repeat 3x) |
| Run all SAST | `python3 scripts/sast-orchestrator.py all` |
| Check expiring creds | `python3 scripts/vault-secrets-manager.py check-expiry` |
| Rotate credentials | `python3 scripts/vault-secrets-manager.py rotate-all` |
| List secrets | `python3 scripts/vault-secrets-manager.py list` |
| View Vault UI | http://localhost:8200 |
| View SAST Report | `open reports/security/sast-report-*.html` |

---

## Next Steps

1. ✅ Vault running and initialized
2. ✅ GitHub Secrets configured
3. ✅ Application secrets updated
4. ✅ First SAST scan completed
5. → **Run CI/CD pipeline** - Push to master to trigger full workflow
6. → **Monitor SAST results** - Check PR comments and artifact uploads
7. → **Schedule rotation** - Set up monthly credential rotation

---

## Support

- 📚 Full documentation: [SAST-AND-SECRETS-GUIDE.md](../docs/SAST-AND-SECRETS-GUIDE.md)
- 🔍 CI/CD integration: [CI_CD_ENHANCEMENT.md](../docs/CI_CD_ENHANCEMENT.md)
- 🏗️ Architecture: See [docs/](../docs) directory
- 🐛 Issues: Check troubleshooting section above

---

**Last Updated:** 2024
**Difficulty:** ⭐⭐⭐ (Intermediate)
**Time to Complete:** ~15 minutes
