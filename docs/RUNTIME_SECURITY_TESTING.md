# Runtime Security Testing Guide
## SSL/TLS, Security Headers & DAST Implementation

---

## Overview

Complete runtime security testing suite for VERMEG SIRH including:

| Test | Purpose | Tools |
|------|---------|-------|
| **SSL/TLS Validation** | Certificate & encryption validation | OpenSSL, Python ssl module |
| **Security Headers** | HTTP header security checks | HTTP requests, validation rules |
| **DAST Scanning** | Dynamic app security testing | Custom Python scanner |

---

## 1. SSL/TLS Validation

### What It Tests

✅ **Certificate Validity**
- Expiration date check
- Certificate chain verification
- Subject Alternative Names (SAN)

✅ **TLS Versions**
- Identify supported versions (SSL 2.0 → TLS 1.3)
- Flag deprecated versions (SSLv3, TLS 1.0/1.1)

✅ **Cipher Suites**
- Detect weak ciphers (DES, RC4, MD5)
- Verify strong encryption algorithms

### Usage

```bash
# Test single host
python3 scripts/ssl-tls-validator.py example.com 443

# Test with custom port
python3 scripts/ssl-tls-validator.py localhost 8443
```

### Example Output

```json
{
  "host": "example.com",
  "port": 443,
  "overall_status": "SECURE",
  "details": {
    "certificate": {
      "status": "VALID",
      "expires": "2025-12-31T23:59:59Z",
      "days_until_expiry": 365
    },
    "tls_versions": {
      "supported": ["TLS 1.2", "TLS 1.3"],
      "secure": true
    },
    "ciphers": {
      "total": 8,
      "strong": 8,
      "weak": 0
    }
  }
}
```

---

## 2. Security Headers Validation

### What It Tests

✅ **Critical Headers**
- `Strict-Transport-Security` (HSTS) - enforces HTTPS
- `X-Content-Type-Options` - prevents MIME sniffing
- `X-Frame-Options` - prevents clickjacking
- `Content-Security-Policy` - XSS/injection protection

✅ **Additional Security**
- `Referrer-Policy` - controls referrer info
- `X-XSS-Protection` - XSS protection (legacy)
- `Permissions-Policy` - browser privileges

✅ **Information Disclosure**
- Flags servers that leak version info
- Detects technology stack disclosure

### Usage

```bash
# Test URL
python3 scripts/security-headers-validator.py https://example.com

# Test with custom port
python3 scripts/security-headers-validator.py http://localhost:5173
```

### Header Requirements

**Required (CRITICAL):**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'self'
```

**Recommended (HIGH):**
```
Referrer-Policy: strict-origin-when-cross-origin
X-XSS-Protection: 1; mode=block
```

### Example Output

```json
{
  "url": "https://example.com",
  "status": "SECURE",
  "score": 95.8,
  "passed": 23,
  "failed": 1,
  "validation_results": [
    {
      "header": "Strict-Transport-Security",
      "present": true,
      "status": "PASS"
    },
    {
      "header": "X-Content-Type-Options",
      "present": true,
      "status": "PASS"
    }
  ]
}
```

---

## 3. DAST (Dynamic Application Security Testing)

### What It Tests

✅ **SQLi Detection**
- SQL injection payloads in parameters
- Database error responses

✅ **XSS Detection**
- Reflected XSS in input parameters
- Script execution vectors

✅ **Security Misconfiguration**
- Exposed admin panels
- Accessible .env, .git, .aws files
- Backup files accessible

✅ **HTTP Methods**
- Dangerous methods (PUT, DELETE, TRACE)
- Unintended resource modification

✅ **Sensitive Data**
- Credit card patterns
- API keys in responses
- AWS access keys
- Private keys

### Usage

```bash
# Scan single application
python3 scripts/dast-scanner.py https://example.com

# Scan local development server
python3 scripts/dast-scanner.py http://localhost:5173
```

### Example Output

```json
{
  "url": "https://example.com",
  "scan_type": "DAST",
  "status": "VULNERABILITIES_FOUND",
  "total_issues": 4,
  "critical": 1,
  "high": 2,
  "medium": 1,
  "low": 0,
  "vulnerabilities": [
    {
      "type": "SQL_Injection",
      "severity": "CRITICAL",
      "parameter": "id",
      "description": "Potential SQL injection detected",
      "remediation": "Use parameterized queries or prepared statements"
    }
  ]
}
```

---

## 4. Integrated Runtime Security Tester

### Overview

Combines all three test suites and generates comprehensive reports.

### Usage

```bash
# Run all tests
python3 scripts/runtime-security-tester.py https://example.com

# Tests local development:
python3 scripts/runtime-security-tester.py http://localhost:5173
```

### Output Files

```
reports/security/
├── runtime-security-report-20240115_101530.html  # Complete HTML report
├── runtime-security-report-20240115_101530.json  # Structured data
└── runtime-security-tests.html                   # Interactive dashboard
```

### Combined Report Structure

```json
{
  "timestamp": "2024-01-15T10:15:30.123456",
  "url": "https://example.com",
  "summary": {
    "overall_status": "WARNINGS",
    "total_issues": 6,
    "critical": 1,
    "high": 2,
    "medium": 2,
    "low": 1,
    "test_results": {
      "ssl_tls": "SECURE",
      "security_headers": "WARNINGS",
      "dast": "VULNERABILITIES_FOUND"
    }
  },
  "tests": {
    "ssl_tls": { /* SSL/TLS results */ },
    "security_headers": { /* Headers results */ },
    "dast": { /* DAST results */ }
  }
}
```

---

## 5. Dashboard Integration

### Runtime Security Tests Dashboard

**Location:** `reports/security/runtime-security-tests.html`

**Features:**
- 📊 Overview tab - summary of all tests
- 🔐 SSL/TLS tab - certificate & encryption details
- 📋 Headers tab - security header validation
- ⚠️ DAST tab - vulnerability findings

### Access Dashboard

```bash
# Start HTTP server
cd reports/security
npx http-server -p 8099 -c-1

# Visit
http://localhost:8099/runtime-security-tests.html
```

---

## 6. CI/CD Integration

### GitHub Actions Workflow

Add to `.github/workflows/ci.yml`:

```yaml
  runtime-security-tests:
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
        run: |
          pip install requests

      - name: Run runtime security tests
        continue-on-error: true
        run: |
          python3 scripts/runtime-security-tester.py https://your-prod-domain.com

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: runtime-security-reports
          path: reports/security/runtime-security-report-*.{html,json}

      - name: Comment on PR with results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '## 🔒 Runtime Security Tests\n\nView detailed results in artifacts.'
            })
```

### Scheduled Testing

Add `security-tests-schedule.yml`:

```yaml
name: Daily Security Tests

on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily

jobs:
  security-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Run comprehensive tests
        run: |
          pip install requests
          python3 scripts/runtime-security-tester.py https://prod.example.com

      - name: Archive results
        run: |
          git add reports/security/
          git config user.name "CI Bot"
          git config user.email "ci@example.com"
          git commit -m "test: daily security scan results"
          git push

      - name: Alert if critical issues
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '🔴 Critical Security Issues Detected',
              body: 'Daily security scan found critical vulnerabilities!'
            })
```

---

## 7. Remediation Guide

### SSL/TLS Issues

**Expired Certificate:**
```bash
# Renew certificate (Let's Encrypt)
certbot renew --cert-name example.com
```

**Weak TLS Versions:**
```nginx
# nginx.conf
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
```

**Weak Ciphers:**
```nginx
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305';
```

### Security Headers Issues

**Add Missing Headers:**

```javascript
// Express.js
const helmet = require('helmet');

app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
  }
}));
```

```nginx
# nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Content-Security-Policy "default-src 'self'" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### DAST Vulnerabilities

**SQL Injection:**
```java
// BAD
String query = "SELECT * FROM users WHERE id = " + userId;

// GOOD
PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
stmt.setInt(1, userId);
```

**XSS Protection:**
```javascript
// Angular
<div [innerHTML]="userContent | sanitize"></div>

// Or use DomSanitizer
constructor(private sanitizer: DomSanitizer) {}

getSafeHtml(html: string) {
  return this.sanitizer.sanitize(SecurityContext.HTML, html);
}
```

**Secure File Upload:**
```python
# Validate file
ALLOWED_EXTENSIONS = {'jpg', 'png', 'gif'}
MAX_FILE_SIZE = 5 * 1024 * 1024

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

if file.size > MAX_FILE_SIZE:
    return "File too large"
```

---

## 8. Best Practices

✅ **SSL/TLS:**
- Minimum TLS 1.2 (recommend 1.3)
- Disable SSLv3, TLS 1.0, TLS 1.1
- Use strong cipher suites
- Certificate renewal before expiry
- HSTS header with `max-age >= 31536000`

✅ **Security Headers:**
- Always use HTTPS
- Implement CSP with restrictive policy
- Prevent MIME sniffing
- Prevent clickjacking
- Control referrer information

✅ **DAST Testing:**
- Input validation & sanitization
- Parameterized queries
- HTML encoding for output
- Disable dangerous HTTP methods
- Never expose sensitive data

✅ **Testing:**
- Run before production deployment
- Schedule weekly/monthly tests
- Monitor for new vulnerabilities
- Keep test tools updated
- Review and remediate issues immediately

---

## 9. Troubleshooting

### SSL/TLS Test Fails

```bash
# Test certificate directly
openssl s_client -connect example.com:443

# Verify chain
openssl s_client -connect example.com:443 -showcerts
```

### Headers Test Returns None

```bash
# Ensure URL is reachable
curl -I https://example.com

# Check firewall/security groups
netstat -tunap | grep 443
```

### DAST Scanner Times Out

```bash
# Increase timeout
python3 scripts/dast-scanner.py https://example.com --timeout=30

# Check application availability
curl https://example.com
```

---

## 10. Compliance

These tests help verify compliance with:

- ✅ OWASP Top 10
- ✅ CWE-295 (Improper SSL/TLS)
- ✅ CWE-693 (Missing headers)
- ✅ CWE-79 (XSS)
- ✅ CWE-89 (SQL Injection)
- ✅ NIST Cybersecurity Framework
- ✅ PCI DSS 6.5.10 (SSL/TLS)

---

## Resources

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [NIST Cybersecurity](https://www.nist.gov/cybersecurity)
- [Mozilla SSL Configuration](https://ssl-config.mozilla.org/)
- [CWE Top 25](https://cwe.mitre.org/top25/)

---

**Last Updated:** January 2024  
**Difficulty:** ⭐⭐⭐ (Intermediate)  
**Time to Implement:** ~2 hours
