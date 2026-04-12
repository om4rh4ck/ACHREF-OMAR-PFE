#!/usr/bin/env python3
"""
Auto-generate professional security insights from scan results
Analyzes each finding and creates actionable recommendations
"""

import json
import re
from datetime import datetime
from pathlib import Path

REPORTS_DIR = Path("reports/security")
INSIGHTS_DIR = REPORTS_DIR / "insights"
INSIGHTS_DIR.mkdir(parents=True, exist_ok=True)


class SecurityAnalyzer:
    def __init__(self):
        self.insights = []
        self.timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    def analyze_owasp_dependency_check(self):
        """Analyze OWASP Dependency-Check results"""
        insights = []
        
        services = ['employee-service', 'recruitment-service', 'approval-service', 'api-gateway']
        
        for service in services:
            report_file = REPORTS_DIR / f"dependency-check-{service}.html"
            if not report_file.exists():
                continue
            
            try:
                with open(report_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                # Count by severity
                critical = len(re.findall(r'CRITICAL', content))
                high = len(re.findall(r'HIGH', content))
                medium = len(re.findall(r'MEDIUM', content))
                low = len(re.findall(r'LOW', content))
                
                if critical > 0:
                    insights.append({
                        'service': service,
                        'type': 'OWASP Dependency',
                        'severity': 'CRITICAL',
                        'issue': f"Found {critical} critical dependency vulnerabilities",
                        'recommendation': f"Immédiatement mettre à jour les dépendances critiques du {service}. Ces vulnérabilités peuvent permettre une exécution de code distant (RCE). Effectuer les mises à jour avant le déploiement en production.",
                        'priority': 1
                    })
                
                if high > 0 and critical == 0:
                    insights.append({
                        'service': service,
                        'type': 'OWASP Dependency',
                        'severity': 'HIGH',
                        'issue': f"Found {high} high-severity dependency vulnerabilities",
                        'recommendation': f"Planifier la mise à jour des dépendances à haut risque du {service} dans les 7 jours. Tester les mises à jour de dépendances dans un environnement de test avant le déploiement.",
                        'priority': 2
                    })
                
                if critical == 0 and high == 0 and (medium > 0 or low > 0):
                    insights.append({
                        'service': service,
                        'type': 'OWASP Dependency',
                        'severity': 'MEDIUM/LOW',
                        'issue': f"Found {medium} medium and {low} low severity issues",
                        'recommendation': f"Inclure les mises à jour du {service} dans le prochain cycle de maintenance régulier. Vérifier la compatibilité avant la mise en production.",
                        'priority': 4
                    })
                
                if critical == 0 and high == 0 and medium == 0 and low == 0:
                    insights.append({
                        'service': service,
                        'type': 'OWASP Dependency',
                        'severity': 'CLEAN',
                        'issue': "No vulnerabilities detected",
                        'recommendation': f"✅ Le {service} n'a pas de vulnérabilités de dépendances détectées. Continuer à surveiller avec les scans réguliers.",
                        'priority': 5
                    })
            
            except Exception as e:
                print(f"⚠️ Error analyzing {service}: {e}")
        
        return insights
    
    def analyze_trivy_scan(self):
        """Analyze Trivy container image scan results"""
        insights = []
        
        services = ['employee-service', 'recruitment-service', 'approval-service', 'api-gateway', 'frontend']
        
        for service in services:
            report_file = REPORTS_DIR / f"trivy-{service}.html"
            if not report_file.exists():
                continue
            
            try:
                with open(report_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                critical = len(re.findall(r'CRITICAL|severity.*critical', content, re.IGNORECASE))
                high = len(re.findall(r'HIGH|severity.*high', content, re.IGNORECASE))
                medium = len(re.findall(r'MEDIUM|severity.*medium', content, re.IGNORECASE))
                low = len(re.findall(r'LOW|severity.*low', content, re.IGNORECASE))
                
                if critical > 0:
                    insights.append({
                        'service': service,
                        'type': 'Trivy Container Image',
                        'severity': 'CRITICAL',
                        'issue': f"Image contient {critical} vulnérabilités critiques détectées",
                        'recommendation': f"🔴 URGENT: Reconstruire l'image Docker du {service} avec des versions de base à jour (ex: FROM openjdk:21-slim au lieu de versions plus anciennes). Appliquer les correctifs de sécurité. Ne pas utiliser en production tant que ces vulnérabilités ne sont pas corrigées.",
                        'priority': 1
                    })
                
                if high > 0 and critical == 0:
                    insights.append({
                        'service': service,
                        'type': 'Trivy Container Image',
                        'severity': 'HIGH',
                        'issue': f"Image contient {high} vulnérabilités à haut risque",
                        'recommendation': f"Mettre à jour l'image de base du {service} et reconstruire le conteneur. Examiner le Dockerfile pour les dépendances optionnelles qui pourraient être supprimées. Tester l'image reconstruite avant le déploiement.",
                        'priority': 2
                    })
                
                if critical == 0 and high == 0 and (medium > 0 or low > 0):
                    insights.append({
                        'service': service,
                        'type': 'Trivy Container Image',
                        'severity': 'MEDIUM/LOW',
                        'issue': f"Image contient {medium} problèmes medium et {low} problèmes low",
                        'recommendation': f"Planifier une mise à jour de l'image de base du {service} dans le prochain cycle de compilation. Les problèmes medium peuvent être adressés dans 30 jours.",
                        'priority': 4
                    })
                
                if critical == 0 and high == 0 and medium == 0 and low == 0:
                    insights.append({
                        'service': service,
                        'type': 'Trivy Container Image',
                        'severity': 'CLEAN',
                        'issue': "L'image Container n'a pas de vulnérabilités détectées",
                        'recommendation': f"✅ L'image Docker du {service} est sécurisée. Maintenir les mises à jour automatiques de l'image de base.",
                        'priority': 5
                    })
            
            except Exception as e:
                print(f"⚠️ Error scanning {service}: {e}")
        
        return insights
    
    def analyze_npm_audit(self):
        """Analyze npm audit findings"""
        insights = []
        
        npm_file = REPORTS_DIR / "npm-audit.txt"
        if npm_file.exists():
            try:
                with open(npm_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                # Look for vulnerability counts
                critical = len(re.findall(r'critical', content, re.IGNORECASE))
                high = len(re.findall(r'high', content, re.IGNORECASE))
                
                if 'audited' in content:
                    if critical > 0:
                        insights.append({
                            'service': 'frontend',
                            'type': 'npm Audit',
                            'severity': 'CRITICAL',
                            'issue': f"Application Angular a {critical} dépendances critiquement vulnérables",
                            'recommendation': "Exécuter 'npm audit fix' pour mettre à jour automatiquement les dépendances. Tester l'application après la mise à jour. Si 'npm audit fix' est insuffisant, mettre à jour manuellement les packages problématiques.",
                            'priority': 2
                        })
                    elif high > 0:
                        insights.append({
                            'service': 'frontend',
                            'type': 'npm Audit',
                            'severity': 'HIGH',
                            'issue': f"Frontend Angular a {high} dépendances à risque élevé",
                            'recommendation': "Exécuter 'npm audit fix --force' pour mettre à jour les dépendances. Vérifier la compatibilité avec Angular 20+ et les composants existants.",
                            'priority': 3
                        })
                    else:
                        insights.append({
                            'service': 'frontend',
                            'type': 'npm Audit',
                            'severity': 'CLEAN',
                            'issue': "Aucune vulnérabilité critique npm détectée",
                            'recommendation': "✅ Les dépendances npm sont à jour. Mettre à jour les dépendances mineures dans les versions de patch.",
                            'priority': 5
                        })
            except Exception as e:
                print(f"⚠️ Error analyzing npm audit: {e}")
        
        return insights
    
    def analyze_gitleaks(self):
        """Analyze GitLeaks secret detection results"""
        insights = []
        
        gitleaks_file = REPORTS_DIR / "gitleaks-report.txt"
        if gitleaks_file.exists():
            try:
                with open(gitleaks_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                if 'no leaks detected' in content.lower() or content.strip() == '':
                    insights.append({
                        'service': 'Repository',
                        'type': 'GitLeaks Secret Detection',
                        'severity': 'CLEAN',
                        'issue': "Aucun secret ou données sensibles détectés",
                        'recommendation': "✅ Aucune clé d'API, mot de passe ou token détectés dans le code source. Continuer à respecter la politique de sécurité des secrets.",
                        'priority': 5
                    })
                else:
                    if 'api' in content.lower() or 'password' in content.lower() or 'token' in content.lower():
                        insights.append({
                            'service': 'Repository',
                            'type': 'GitLeaks Secret Detection',
                            'severity': 'CRITICAL',
                            'issue': "Des secrets potentiels ont été détectés dans l'historique Git",
                            'recommendation': "🔴 URGENT: Ignorer immédiatement les secrets détectés. Rotation des clés/tokens exposés si applicable. Utiliser .gitignore pour exclure les fichiers de configuration sensibles. Implémenter un gestionnaire de secrets (ex: HashiCorp Vault, AWS Secrets Manager).",
                            'priority': 1
                        })
            except Exception as e:
                print(f"⚠️ Error analyzing GitLeaks: {e}")
        
        return insights
    
    def generate_report(self):
        """Generate comprehensive insights report"""
        all_insights = []
        all_insights.extend(self.analyze_owasp_dependency_check())
        all_insights.extend(self.analyze_trivy_scan())
        all_insights.extend(self.analyze_npm_audit())
        all_insights.extend(self.analyze_gitleaks())
        
        # Sort by priority
        all_insights.sort(key=lambda x: x['priority'])
        
        # Generate HTML report
        html_content = f"""
        <!DOCTYPE html>
        <html lang="fr">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Security Insights Report</title>
            <style>
                body {{
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    margin: 0;
                    padding: 20px;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    min-height: 100vh;
                }}
                
                .container {{
                    max-width: 1200px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 12px;
                    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                    overflow: hidden;
                }}
                
                .header {{
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 30px;
                    text-align: center;
                }}
                
                .header h1 {{
                    margin: 0;
                    font-size: 2.5em;
                }}
                
                .header p {{
                    margin: 10px 0 0 0;
                    opacity: 0.9;
                }}
                
                .content {{
                    padding: 30px;
                }}
                
                .insight-card {{
                    margin-bottom: 20px;
                    border-left: 5px solid #667eea;
                    padding: 20px;
                    background: #f9f9f9;
                    border-radius: 6px;
                }}
                
                .insight-card.critical {{
                    border-left-color: #e74c3c;
                    background: #fdeaea;
                }}
                
                .insight-card.high {{
                    border-left-color: #e67e22;
                    background: #fdf3e9;
                }}
                
                .insight-card.medium {{
                    border-left-color: #f39c12;
                    background: #fef9e9;
                }}
                
                .insight-card.low {{
                    border-left-color: #f1c40f;
                    background: #fffde9;
                }}
                
                .insight-card.clean {{
                    border-left-color: #27ae60;
                    background: #eafce9;
                }}
                
                .insight-header {{
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 10px;
                }}
                
                .severity {{
                    display: inline-block;
                    padding: 5px 12px;
                    border-radius: 20px;
                    font-size: 0.85em;
                    font-weight: bold;
                    color: white;
                }}
                
                .severity.critical {{
                    background: #e74c3c;
                }}
                
                .severity.high {{
                    background: #e67e22;
                }}
                
                .severity.medium {{
                    background: #f39c12;
                }}
                
                .severity.low {{
                    background: #f1c40f;
                    color: #333;
                }}
                
                .severity.clean {{
                    background: #27ae60;
                }}
                
                .service-badge {{
                    display: inline-block;
                    background: #ecf0f1;
                    padding: 4px 10px;
                    border-radius: 4px;
                    font-size: 0.9em;
                    margin: 5px 5px 5px 0;
                    color: #2c3e50;
                }}
                
                .issue {{
                    margin: 10px 0;
                    font-weight: 500;
                    color: #2c3e50;
                }}
                
                .recommendation {{
                    background: white;
                    padding: 15px;
                    border-radius: 4px;
                    margin: 10px 0;
                    border-left: 3px solid #3498db;
                    line-height: 1.6;
                    color: #34495e;
                }}
                
                .stats {{
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                    gap: 15px;
                    margin-bottom: 30px;
                }}
                
                .stat-box {{
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 20px;
                    border-radius: 8px;
                    text-align: center;
                }}
                
                .stat-box h3 {{
                    margin: 0;
                    font-size: 2em;
                }}
                
                .stat-box p {{
                    margin: 5px 0 0 0;
                    opacity: 0.9;
                }}
                
                .footer {{
                    background: #ecf0f1;
                    padding: 20px;
                    text-align: center;
                    color: #7f8c8d;
                    font-size: 0.9em;
                    border-top: 1px solid #bdc3c7;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🔐 Security Insights Report</h1>
                    <p>VERMEG SIRH Platform - {self.timestamp}</p>
                </div>
                
                <div class="content">
                    <div class="stats">
                        <div class="stat-box">
                            <h3>{len([i for i in all_insights if i['severity'] == 'CRITICAL'])}</h3>
                            <p>🔴 Critical Issues</p>
                        </div>
                        <div class="stat-box">
                            <h3>{len([i for i in all_insights if i['severity'] == 'HIGH'])}</h3>
                            <p>🟠 High Priority</p>
                        </div>
                        <div class="stat-box">
                            <h3>{len([i for i in all_insights if i['severity'] == 'MEDIUM/LOW'])}</h3>
                            <p>🟡 Medium Priority</p>
                        </div>
                        <div class="stat-box">
                            <h3>{len([i for i in all_insights if i['severity'] == 'CLEAN'])}</h3>
                            <p>✅ Clean</p>
                        </div>
                    </div>
        """
        
        # Add insights
        for insight in all_insights:
            severity_class = insight['severity'].lower().replace('/', '')
            html_content += f"""
            <div class="insight-card {severity_class}">
                <div class="insight-header">
                    <div>
                        <h3>{insight['type']}</h3>
                        <div class="service-badge">{insight['service']}</div>
                    </div>
                    <span class="severity {severity_class}">{insight['severity']}</span>
                </div>
                <div class="issue">📌 {insight['issue']}</div>
                <div class="recommendation">
                    <strong>💡 Action Recommandée:</strong><br/>
                    {insight['recommendation']}
                </div>
            </div>
            """
        
        html_content += """
                </div>
                
                <div class="footer">
                    <p><strong>VERMEG Security Team</strong> | Rapport généré automatiquement via CI/CD</p>
                    <p>Pour questions ou escalade: security@vermeg.com</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        # Write report
        report_file = INSIGHTS_DIR / f"insights-{datetime.now().strftime('%Y-%m-%d')}.html"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print(f"✅ Insights report generated: {report_file}")
        
        # Also save JSON for processing
        json_file = INSIGHTS_DIR / f"insights-{datetime.now().strftime('%Y-%m-%d')}.json"
        with open(json_file, 'w') as f:
            json.dump(all_insights, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Insights JSON saved: {json_file}")
        
        return all_insights


if __name__ == "__main__":
    print("🔍 Analyzing security scan results...")
    analyzer = SecurityAnalyzer()
    insights = analyzer.generate_report()
    print(f"✅ Generated {len(insights)} security insights")
