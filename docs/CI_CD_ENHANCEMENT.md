# Enhanced CI/CD Workflow - SAST and Secret Management Integration
# This file shows how to integrate the new security features into the existing workflow

## Key Additions:

### 1. Vault Secret Retrieval Job
```yaml
vault-secrets:
  runs-on: ubuntu-latest
  if: ${{ github.event_name == 'push' || github.event_name == 'pull_request' }}
  outputs:
    sonar-token: ${{ steps.vault.outputs.sonar_token }}
    snyk-token: ${{ steps.vault.outputs.snyk_token }}
  steps:
    - name: Retrieve secrets from Vault
      id: vault
      uses: hashicorp/vault-action@v2
      with:
        url: ${{ secrets.VAULT_ADDR }}
        method: approle
        roleId: ${{ secrets.VAULT_ROLE_ID }}
        secretId: ${{ secrets.VAULT_SECRET_ID }}
        secrets: |
          cicd/api-keys sonar_token | sonar_token ;
          cicd/api-keys snyk_token | snyk_token ;
          cicd/database username | db_username ;
          cicd/database password | db_password
```

### 2. SAST Scanning Job
```yaml
sast-scan:
  runs-on: ubuntu-latest
  needs: [backend-build, frontend-build, vault-secrets]
  if: ${{ github.event_name == 'push' && !contains(github.event.head_commit.message, '[skip ci]') }}
  steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install security tools
      run: |
        pip install -r requirements-security.txt
        pip install bandit semgrep

    - name: Run SAST orchestration
      env:
        SONAR_TOKEN: ${{ needs.vault-secrets.outputs.sonar-token }}
      run: |
        python3 scripts/sast-orchestrator.py all

    - name: Upload SAST reports
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: sast-reports
        path: reports/security/sast-report-*.html

    - name: Comment PR with SAST results
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          const reports = fs.readdirSync('reports/security')
            .filter(f => f.startsWith('sast-report'))
            .map(f => `- [${f}](${f})`);
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: '## 🔒 SAST Scan Results\n\n' + reports.join('\n')
          });
```

### 3. Credential Rotation Check
```yaml
security-check:
  runs-on: ubuntu-latest
  if: ${{ github.event_name == 'push' && github.ref == 'refs/heads/master' }}
  steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: pip install -r requirements-security.txt

    - name: Authenticate with Vault
      uses: hashicorp/vault-action@v2
      with:
        url: ${{ secrets.VAULT_ADDR }}
        method: approle
        roleId: ${{ secrets.VAULT_ROLE_ID }}
        secretId: ${{ secrets.VAULT_SECRET_ID }}

    - name: Check expiring credentials
      run: |
        python3 scripts/vault-secrets-manager.py check-expiry

    - name: Create security issue if needed
      if: failure()
      uses: actions/github-script@v6
      with:
        script: |
          github.rest.issues.create({
            owner: context.repo.owner,
            repo: context.repo.repo,
            title: '🔐 Credentials Rotation Required',
            body: 'Some credentials are expiring within 30 days. Please run rotation job.'
          });
```

## Integration Steps:

1. **Add to existing CI/CD:**
   - Insert vault-secrets job early (before builds that need credentials)
   - Add sast-scan job after builds
   - Add security-check job for master branch

2. **Update needs dependencies:**
   - sonar job: `needs: [backend-build, frontend-build, vault-secrets]`
   - security-reports: use VAULT secrets instead of GitHub secrets
   - docker-push: retrieve credentials from vault

3. **Example complete job with Vault:**
```yaml
backend-build:
  runs-on: ubuntu-latest
  needs: [vault-secrets]
  steps:
    - name: Build with vault credentials
      env:
        DB_USER: ${{ needs.vault-secrets.outputs.db_username }}
        DB_PASSWORD: ${{ needs.vault-secrets.outputs.db_password }}
      run: |
        mvn clean package
```
