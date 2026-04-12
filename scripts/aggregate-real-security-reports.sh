#!/bin/bash

# Aggregate real security scan results and update dashboard

REPORTS_DIR="reports/security"
DASHBOARD_FILE="$REPORTS_DIR/index.html"

echo "=== AGGREGATING SECURITY SCAN RESULTS ==="

# Parse OWASP Dependency-Check reports
parse_owasp_counts() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "0 0 0 0"
        return
    fi
    
    # Count severity levels from HTML
    local critical=$(grep -o "CRITICAL" "$file" | wc -l)
    local high=$(grep -o "HIGH" "$file" | wc -l)
    local medium=$(grep -o "MEDIUM" "$file" | wc -l)
    local low=$(grep -o "LOW" "$file" | wc -l)
    
    echo "$critical $high $medium $low"
}

# Parse Trivy scan results
parse_trivy_counts() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "0 0 0 0"
        return
    fi
    
    # Extract severity counts from Trivy HTML
    local critical=$(grep -o 'CRITICAL' "$file" | wc -l)
    local high=$(grep -o 'HIGH' "$file" | wc -l)
    local medium=$(grep -o 'MEDIUM' "$file" | wc -l)
    local low=$(grep -o 'LOW' "$file" | wc -l)
    
    echo "$critical $high $medium $low"
}

# Initialize counters
total_critical=0
total_high=0
total_medium=0
total_low=0

# Count OWASP results
echo "[OWASP] Parsing reports..."
for service in employee-service recruitment-service approval-service api-gateway; do
    file="$REPORTS_DIR/dependency-check-$service.html"
    if [ -f "$file" ]; then
        read crit high med low < <(parse_owasp_counts "$file")
        echo "  - $service: $crit Critical, $high High, $med Medium, $low Low"
        total_critical=$((total_critical + crit))
        total_high=$((total_high + high))
        total_medium=$((total_medium + med))
        total_low=$((total_low + low))
    fi
done

# Count Trivy results
echo "[TRIVY] Parsing reports..."
for service in employee-service recruitment-service approval-service api-gateway frontend; do
    file="$REPORTS_DIR/trivy-$service.html"
    if [ -f "$file" ]; then
        read crit high med low < <(parse_trivy_counts "$file")
        echo "  - $service: $crit Critical, $high High, $med Medium, $low Low"
        total_critical=$((total_critical + crit))
        total_high=$((total_high + high))
        total_medium=$((total_medium + med))
        total_low=$((total_low + low))
    fi
done

# Count npm audit
echo "[npm audit] Checking results..."
if [ -f "$REPORTS_DIR/npm-audit.txt" ]; then
    npm_vulnerabilities=$(grep -o "vulnerabilities" "$REPORTS_DIR/npm-audit.txt" | wc -l)
    if [ "$npm_vulnerabilities" -gt 0 ]; then
        npm_high=$(grep -i "high\|moderate" "$REPORTS_DIR/npm-audit.txt" | wc -l)
        echo "  - npm: Found vulnerabilities: $npm_high"
        total_high=$((total_high + npm_high))
    else
        echo "  - npm: No vulnerabilities"
    fi
fi

echo ""
echo "=== AGGREGATED RESULTS ==="
echo "Critical: $total_critical"
echo "High: $total_high"
echo "Medium: $total_medium"
echo "Low: $total_low"
echo "Total: $((total_critical + total_high + total_medium + total_low))"
echo ""

# Generate updated dashboard with real counts
cat > "$DASHBOARD_FILE" <<EOF
<!doctype html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>VERMEG SECURITY REVIEW</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="styles.css" />
  </head>
  <body>
    <div class="app">
      <aside class="sidebar">
        <div class="brand">
          <div class="brand-mark">/</div>
          <div class="brand-text">
            <div class="brand-title">VERMEG</div>
            <div class="brand-subtitle">SECURITY REVIEW</div>
          </div>
        </div>
        <nav class="menu">
          <a class="menu-item active" href="#overview">
            <span class="menu-icon">🛡️</span>
            <span class="menu-text">Overview</span>
          </a>
          <a class="menu-item" href="#owasp">
            <span class="menu-icon">🔎</span>
            <span class="menu-text">OWASP</span>
          </a>
          <a class="menu-item" href="#trivy">
            <span class="menu-icon">🐳</span>
            <span class="menu-text">Trivy</span>
          </a>
          <a class="menu-item" href="#snyk">
            <span class="menu-icon">🧪</span>
            <span class="menu-text">Snyk</span>
          </a>
          <a class="menu-item" href="#npm">
            <span class="menu-icon">📦</span>
            <span class="menu-text">npm audit</span>
          </a>
        </nav>
        <div class="sidebar-footer">
          <div class="badge">Derniere mise a jour</div>
          <div class="small muted" id="last-updated">-</div>
        </div>
      </aside>

      <main class="content">
        <header class="topbar">
          <div>
            <div class="eyebrow">SECURITY CENTER</div>
            <h1>VERMEG SECURITY REVIEW</h1>
            <p class="subtitle">Dashboard de securite unifie pour OWASP, Trivy et Snyk.</p>
          </div>
          <div class="topbar-actions">
            <button class="chip critical">Critical: $total_critical</button>
            <button class="chip high">High: $total_high</button>
            <button class="chip medium">Medium: $total_medium</button>
            <button class="chip low">Low: $total_low</button>
          </div>
        </header>

        <section id="overview" class="grid">
          <div class="card">
            <div class="card-icon">🛡️</div>
            <div class="card-title">Vulnerabilites totales</div>
            <div class="card-value">$((total_critical + total_high + total_medium + total_low))</div>
            <div class="card-caption">OWASP + Trivy + npm</div>
          </div>
          <div class="card">
            <div class="card-icon">🔴</div>
            <div class="card-title">Critical</div>
            <div class="card-value">$total_critical</div>
            <div class="card-caption">Action immediates</div>
          </div>
          <div class="card">
            <div class="card-icon">🟠</div>
            <div class="card-title">High</div>
            <div class="card-value">$total_high</div>
            <div class="card-caption">A corriger</div>
          </div>
          <div class="card">
            <div class="card-icon">🟡</div>
            <div class="card-title">Medium + Low</div>
            <div class="card-value">$((total_medium + total_low))</div>
            <div class="card-caption">A monitorer</div>
          </div>
        </section>

        <section class="panel" id="owasp">
          <div class="panel-header">
            <h2>OWASP Dependency-Check</h2>
            <span class="pill">Java + npm</span>
          </div>
          <p class="panel-text">Rapport des vulnerabilites des dependances Maven.</p>
          <div class="links">
            <a class="link-button" href="dependency-check-employee-service.html">Employee Service</a>
            <a class="link-button" href="dependency-check-recruitment-service.html">Recruitment Service</a>
            <a class="link-button" href="dependency-check-approval-service.html">Approval Service</a>
            <a class="link-button" href="dependency-check-api-gateway.html">API Gateway</a>
          </div>
        </section>

        <section class="panel" id="trivy">
          <div class="panel-header">
            <h2>Trivy Image Scan</h2>
            <span class="pill">Docker Images</span>
          </div>
          <p class="panel-text">Scan des images Docker de tous les services.</p>
          <div class="links">
            <a class="link-button" href="trivy-employee-service.html">Employee Service</a>
            <a class="link-button" href="trivy-recruitment-service.html">Recruitment Service</a>
            <a class="link-button" href="trivy-approval-service.html">Approval Service</a>
            <a class="link-button" href="trivy-api-gateway.html">API Gateway</a>
            <a class="link-button" href="trivy-frontend.html">Frontend</a>
          </div>
        </section>

        <section class="panel" id="snyk">
          <div class="panel-header">
            <h2>Snyk Continuous Analysis</h2>
            <span class="pill">CI/CD</span>
          </div>
          <p class="panel-text">Analyse continue des dependances et packages.</p>
          <div class="links">
            <a class="link-button" href="snyk-backend.txt">Snyk Backend</a>
            <a class="link-button" href="snyk-frontend.txt">Snyk Frontend</a>
          </div>
        </section>

        <section class="panel" id="npm">
          <div class="panel-header">
            <h2>npm audit</h2>
            <span class="pill">Frontend</span>
          </div>
          <p class="panel-text">Rapport npm audit du frontend Angular.</p>
          <div class="links">
            <a class="link-button" href="npm-audit.txt">Ouvrir npm audit</a>
          </div>
        </section>
      </main>
    </div>

    <script>
      const now = new Date();
      const dateText = now.toLocaleString("fr-FR");
      const scanDate = document.getElementById("scan-date");
      const lastUpdated = document.getElementById("last-updated");
      if (lastUpdated) lastUpdated.textContent = dateText;
    </script>
  </body>
</html>
EOF

echo "✅ Dashboard updated: $DASHBOARD_FILE"
