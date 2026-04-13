#!/usr/bin/env python3
"""
Runtime Security Testing Orchestrator
Combines SSL/TLS validation, security headers check, and DAST scanning
Integrates all results into security dashboard
"""

import os
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional
import sys

# Add scripts to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ssl_tls_validator import SSLTLSValidator
from security_headers_validator import SecurityHeadersValidator
from dast_scanner import DASTScanner

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class RuntimeSecurityTester:
    """Orchestrates all runtime security tests"""
    
    def __init__(self, base_url: str, output_dir: str = 'reports/security'):
        """
        Initialize runtime security tester
        
        Args:
            base_url: Application base URL
            output_dir: Output directory for reports
        """
        self.base_url = base_url
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'url': base_url,
            'tests': {}
        }
    
    def test_ssl_tls(self) -> Dict:
        """Run SSL/TLS validation"""
        logger.info("Starting SSL/TLS validation...")
        
        try:
            # Extract host and port from URL
            from urllib.parse import urlparse
            
            parsed = urlparse(self.base_url)
            host = parsed.hostname
            port = parsed.port or (443 if parsed.scheme == 'https' else 80)
            
            if parsed.scheme != 'https':
                logger.warning("URL is not HTTPS, skipping SSL/TLS test")
                return {
                    'status': 'SKIPPED',
                    'reason': 'Not an HTTPS URL',
                    'timestamp': datetime.now().isoformat()
                }
            
            validator = SSLTLSValidator(host, port)
            result = validator.run_all_checks()
            
            logger.info("SSL/TLS validation complete")
            self.results['tests']['ssl_tls'] = result
            
            return result
        
        except Exception as e:
            logger.error(f"SSL/TLS test failed: {e}")
            result = {
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
            self.results['tests']['ssl_tls'] = result
            return result
    
    def test_security_headers(self) -> Dict:
        """Run security headers validation"""
        logger.info("Starting security headers validation...")
        
        try:
            validator = SecurityHeadersValidator(self.base_url)
            result = validator.validate_all()
            
            logger.info("Security headers validation complete")
            self.results['tests']['security_headers'] = result
            
            return result
        
        except Exception as e:
            logger.error(f"Security headers test failed: {e}")
            result = {
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
            self.results['tests']['security_headers'] = result
            return result
    
    def test_dast(self) -> Dict:
        """Run DAST scanning"""
        logger.info("Starting DAST scanning...")
        
        try:
            scanner = DASTScanner(self.base_url)
            result = scanner.scan_all()
            
            logger.info("DAST scanning complete")
            self.results['tests']['dast'] = result
            
            return result
        
        except Exception as e:
            logger.error(f"DAST test failed: {e}")
            result = {
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
            self.results['tests']['dast'] = result
            return result
    
    def aggregate_results(self) -> Dict:
        """Aggregate all test results"""
        logger.info("Aggregating test results...")
        
        # Count issues by severity
        critical = 0
        high = 0
        medium = 0
        low = 0
        
        for test_name, test_result in self.results['tests'].items():
            if 'vulnerabilities' in test_result:
                for vuln in test_result['vulnerabilities']:
                    severity = vuln.get('severity', 'UNKNOWN')
                    if severity == 'CRITICAL':
                        critical += 1
                    elif severity == 'HIGH':
                        high += 1
                    elif severity == 'MEDIUM':
                        medium += 1
                    elif severity == 'LOW':
                        low += 1
            
            # Handle DAST-specific counts
            if test_name == 'dast':
                critical += test_result.get('critical', 0)
                high += test_result.get('high', 0)
                medium += test_result.get('medium', 0)
                low += test_result.get('low', 0)
        
        # Overall assessment
        overall_status = 'SECURE'
        if critical > 0:
            overall_status = 'CRITICAL'
        elif high > 0:
            overall_status = 'WARNINGS'
        
        self.results['summary'] = {
            'overall_status': overall_status,
            'total_issues': critical + high + medium + low,
            'critical': critical,
            'high': high,
            'medium': medium,
            'low': low,
            'test_results': {
                'ssl_tls': self.results['tests'].get('ssl_tls', {}).get('overall_status', 'UNKNOWN'),
                'security_headers': self.results['tests'].get('security_headers', {}).get('status', 'UNKNOWN'),
                'dast': self.results['tests'].get('dast', {}).get('status', 'UNKNOWN')
            }
        }
        
        return self.results['summary']
    
    def generate_html_report(self) -> str:
        """Generate comprehensive HTML report"""
        logger.info("Generating HTML report...")
        
        report_file = self.output_dir / f'runtime-security-report-{self.timestamp}.html'
        
        ssl_data = self.results['tests'].get('ssl_tls', {})
        headers_data = self.results['tests'].get('security_headers', {})
        dast_data = self.results['tests'].get('dast', {})
        summary = self.results.get('summary', {})
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Runtime Security Test Report - VERMEG SIRH</title>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                * {{
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }}
                
                body {{
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
                    color: #333;
                    line-height: 1.6;
                }}
                
                .container {{
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 20px;
                }}
                
                .header {{
                    background: white;
                    padding: 40px;
                    border-radius: 8px;
                    margin-bottom: 30px;
                    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
                }}
                
                .header h1 {{
                    color: #0f172a;
                    margin-bottom: 10px;
                    font-size: 2.5em;
                }}
                
                .header p {{
                    color: #666;
                    font-size: 1.1em;
                }}
                
                .summary-cards {{
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                    gap: 20px;
                    margin-bottom: 30px;
                }}
                
                .summary-card {{
                    background: white;
                    padding: 20px;
                    border-radius: 8px;
                    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                    text-align: center;
                }}
                
                .summary-card h3 {{
                    color: #666;
                    font-size: 0.9em;
                    text-transform: uppercase;
                    margin-bottom: 10px;
                }}
                
                .summary-card .value {{
                    font-size: 2.5em;
                    font-weight: bold;
                    margin: 10px 0;
                }}
                
                .status-critical {{ color: #dc2626; }}
                .status-high {{ color: #f97316; }}
                .status-medium {{ color: #eab308; }}
                .status-low {{ color: #10b981; }}
                .status-secure {{ color: #10b981; }}
                .status-warnings {{ color: #f97316; }}
                
                .test-section {{
                    background: white;
                    padding: 30px;
                    border-radius: 8px;
                    margin-bottom: 20px;
                    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                }}
                
                .test-section h2 {{
                    color: #0f172a;
                    margin-bottom: 20px;
                    border-bottom: 3px solid #06b6d4;
                    padding-bottom: 10px;
                    font-size: 1.8em;
                }}
                
                .test-result {{
                    background: #f9fafb;
                    padding: 15px;
                    margin: 10px 0;
                    border-radius: 4px;
                    border-left: 4px solid #06b6d4;
                }}
                
                .issue {{
                    background: #fff5f5;
                    padding: 15px;
                    margin: 10px 0;
                    border-radius: 4px;
                    border-left: 4px solid;
                }}
                
                .issue.critical {{ border-left-color: #dc2626; }}
                .issue.high {{ border-left-color: #f97316; }}
                .issue.medium {{ border-left-color: #eab308; }}
                .issue.low {{ border-left-color: #10b981; }}
                
                .issue-title {{
                    font-weight: bold;
                    margin-bottom: 5px;
                }}
                
                .issue-severity {{
                    display: inline-block;
                    padding: 3px 8px;
                    border-radius: 3px;
                    font-size: 0.85em;
                    font-weight: bold;
                    color: white;
                    margin-right: 10px;
                }}
                
                .issue-critical {{ background-color: #dc2626; }}
                .issue-high {{ background-color: #f97316; }}
                .issue-medium {{ background-color: #eab308; color: #000; }}
                .issue-low {{ background-color: #10b981; }}
                
                .remediation {{
                    background: #f0fdf4;
                    padding: 10px;
                    margin-top: 10px;
                    border-radius: 3px;
                    border-left: 3px solid #10b981;
                }}
                
                .remediation strong {{
                    color: #166534;
                }}
                
                .pass {{ color: #10b981; font-weight: bold; }}
                .fail {{ color: #dc2626; font-weight: bold; }}
                .warning {{ color: #f97316; font-weight: bold; }}
                
                footer {{
                    text-align: center;
                    margin-top: 40px;
                    padding: 20px;
                    color: #999;
                    font-size: 0.9em;
                }}
                
                .timestamp {{
                    color: #666;
                    font-size: 0.9em;
                    margin-top: 10px;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🔒 Runtime Security Test Report</h1>
                    <p><strong>Application:</strong> {self.base_url}</p>
                    <p class="timestamp"><strong>Generated:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
                </div>
                
                <div class="summary-cards">
                    <div class="summary-card">
                        <h3>Overall Status</h3>
                        <div class="value status-{summary.get('overall_status', 'UNKNOWN').lower()}">
                            {summary.get('overall_status', 'UNKNOWN')}
                        </div>
                    </div>
                    <div class="summary-card">
                        <h3>Critical Issues</h3>
                        <div class="value status-critical">{summary.get('critical', 0)}</div>
                    </div>
                    <div class="summary-card">
                        <h3>High Severity</h3>
                        <div class="value status-high">{summary.get('high', 0)}</div>
                    </div>
                    <div class="summary-card">
                        <h3>Medium/Low</h3>
                        <div class="value status-medium">{summary.get('medium', 0) + summary.get('low', 0)}</div>
                    </div>
                </div>
        """
        
        # SSL/TLS Section
        html_content += self._generate_ssl_section(ssl_data)
        
        # Security Headers Section
        html_content += self._generate_headers_section(headers_data)
        
        # DAST Section
        html_content += self._generate_dast_section(dast_data)
        
        # Footer
        html_content += """
                <footer>
                    <p>This report was automatically generated by VERMEG Security Suite</p>
                    <p>For more information, visit: <a href="https://github.com/om4rh4ck/ACHREF-OMAR-PFE" style="color: #06b6d4;">Project Repository</a></p>
                </footer>
            </div>
        </body>
        </html>
        """
        
        with open(report_file, 'w') as f:
            f.write(html_content)
        
        logger.info(f"HTML report generated: {report_file}")
        return str(report_file)
    
    def _generate_ssl_section(self, data: Dict) -> str:
        """Generate SSL/TLS section of report"""
        if not data or data.get('status') == 'SKIPPED':
            return """
            <div class="test-section">
                <h2>🔐 SSL/TLS Configuration</h2>
                <p><span class="warning">SKIPPED</span> - Not an HTTPS URL</p>
            </div>
            """
        
        cert = data.get('details', {}).get('certificate', {})
        tls = data.get('details', {}).get('tls_versions', {})
        
        sections = f"""
        <div class="test-section">
            <h2>🔐 SSL/TLS Configuration</h2>
            <div class="test-result">
                <strong>Certificate Status:</strong> <span class="{'pass' if cert.get('status') == 'VALID' else 'fail'}">{cert.get('status', 'UNKNOWN')}</span>
                <br>Expires: {cert.get('expires', 'Unknown')}
                <br>Days until expiry: {cert.get('days_until_expiry', 'Unknown')}
            </div>
            <div class="test-result">
                <strong>TLS Versions:</strong>
                <br>Supported: {', '.join(tls.get('supported', []))}
                <br>Secure: <span class="{'pass' if tls.get('secure') else 'fail'}">{'✓' if tls.get('secure') else '✗'}</span>
            </div>
        </div>
        """
        
        return sections
    
    def _generate_headers_section(self, data: Dict) -> str:
        """Generate security headers section of report"""
        if not data:
            return ""
        
        passed = data.get('passed', 0)
        failed = data.get('failed', 0)
        score = data.get('score', 0)
        
        sections = f"""
        <div class="test-section">
            <h2>📋 Security Headers Check</h2>
            <div class="test-result">
                <strong>Score:</strong> {score}% ({passed}/{passed+failed} checks passed)
            </div>
        """
        
        for result in data.get('validation_results', []):
            status_class = 'pass' if result['status'] == 'PASS' else 'fail' if result['status'] == 'FAIL' else 'warning'
            sections += f"""
            <div class="test-result">
                <strong>{result['header']}:</strong>
                <span class="{status_class}">{result['status']}</span>
                {f"<br><small>{result.get('issue', '')}</small>" if result.get('issue') else ""}
            </div>
            """
        
        sections += "</div>"
        return sections
    
    def _generate_dast_section(self, data: Dict) -> str:
        """Generate DAST section of report"""
        if not data:
            return ""
        
        sections = f"""
        <div class="test-section">
            <h2>⚠️ Dynamic Application Security Testing (DAST)</h2>
            <div class="test-result">
                <strong>Total Issues Found:</strong> {data.get('total_issues', 0)}
                <br>Critical: {data.get('critical', 0)} | High: {data.get('high', 0)} | Medium: {data.get('medium', 0)} | Low: {data.get('low', 0)}
            </div>
        """
        
        for vuln in data.get('vulnerabilities', []):
            severity = vuln.get('severity', 'UNKNOWN').lower()
            sections += f"""
            <div class="issue {severity}">
                <div class="issue-title">
                    <span class="issue-severity issue-{severity}">{vuln.get('severity', 'UNKNOWN')}</span>
                    {vuln.get('type', 'Unknown Issue')}
                </div>
                <p>{vuln.get('description', '')}</p>
                {f"<div class='remediation'><strong>Fix:</strong> {vuln.get('remediation', '')}</div>" if vuln.get('remediation') else ""}
            </div>
            """
        
        sections += "</div>"
        return sections
    
    def run_all(self) -> Dict:
        """Run all security tests"""
        logger.info("Starting comprehensive runtime security testing...")
        
        self.test_ssl_tls()
        self.test_security_headers()
        self.test_dast()
        
        self.aggregate_results()
        self.generate_html_report()
        self.save_json_report()
        
        logger.info("Runtime security testing complete")
        return self.results
    
    def save_json_report(self) -> str:
        """Save results as JSON"""
        json_file = self.output_dir / f'runtime-security-report-{self.timestamp}.json'
        
        with open(json_file, 'w') as f:
            json.dump(self.results, f, indent=2, default=str)
        
        logger.info(f"JSON report saved: {json_file}")
        return str(json_file)


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 runtime-security-tester.py <url>")
        print("Example: python3 runtime-security-tester.py https://localhost:5173")
        sys.exit(1)
    
    url = sys.argv[1]
    
    tester = RuntimeSecurityTester(url)
    results = tester.run_all()
    
    print("\n" + "="*70)
    print(f"Runtime Security Testing Results for {url}")
    print("="*70)
    print(json.dumps(results, indent=2, default=str))
