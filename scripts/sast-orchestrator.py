#!/usr/bin/env python3
"""
SAST (Static Application Security Testing) Orchestration
Coordinates multiple security scanning tools for comprehensive code analysis
"""

import os
import json
import subprocess
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import xml.etree.ElementTree as ET

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class SASTOrchestrator:
    """Orchestrates multiple SAST tools"""
    
    def __init__(self, project_root: str = '.', output_dir: str = 'reports/security'):
        """
        Initialize SAST orchestrator
        
        Args:
            project_root: Root directory of project
            output_dir: Directory for SAST reports
        """
        self.project_root = Path(project_root)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        self.results = {}
    
    def run_sonarqube(self, sonar_host: str = None, sonar_token: str = None, 
                     project_key: str = None) -> Dict:
        """
        Run SonarQube analysis
        
        Args:
            sonar_host: SonarQube server URL
            sonar_token: SonarQube token
            project_key: Project key
        
        Returns:
            Analysis results
        """
        try:
            sonar_host = sonar_host or os.getenv('SONAR_HOST_URL', 'http://localhost:9000')
            sonar_token = sonar_token or os.getenv('SONAR_TOKEN')
            project_key = project_key or os.getenv('SONAR_PROJECT_KEY', 'vermeg-sirh')
            
            logger.info("Running SonarQube analysis...")
            
            cmd = [
                'sonar-scanner',
                f'-Dsonar.projectKey={project_key}',
                f'-Dsonar.sources=backend,front',
                f'-Dsonar.exclusions=**/target/**,**/dist/**,**/node_modules/**,**/.angular/**',
                f'-Dsonar.host.url={sonar_host}',
                f'-Dsonar.login={sonar_token}',
                f'-Dsonar.java.binaries=backend/*/target/classes',
                '-Dsonar.qualitygate.wait=true'
            ]
            
            result = subprocess.run(cmd, cwd=str(self.project_root), 
                                  capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                logger.info("SonarQube analysis completed successfully")
                self.results['sonarqube'] = {
                    'status': 'SUCCESS',
                    'timestamp': datetime.now().isoformat(),
                    'project_key': project_key,
                    'server': sonar_host
                }
            else:
                logger.warning(f"SonarQube analysis failed: {result.stderr}")
                self.results['sonarqube'] = {
                    'status': 'FAILED',
                    'error': result.stderr,
                    'timestamp': datetime.now().isoformat()
                }
            
            return self.results['sonarqube']
            
        except Exception as e:
            logger.error(f"SonarQube execution failed: {e}")
            self.results['sonarqube'] = {
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
            return self.results['sonarqube']
    
    def run_checkmarx(self, checkmarx_url: str = None, checkmarx_token: str = None) -> Dict:
        """
        Run Checkmarx SAST scan
        
        Args:
            checkmarx_url: Checkmarx server URL
            checkmarx_token: Checkmarx API token
        
        Returns:
            Scan results
        """
        try:
            checkmarx_url = checkmarx_url or os.getenv('CHECKMARX_URL')
            checkmarx_token = checkmarx_token or os.getenv('CHECKMARX_TOKEN')
            
            if not checkmarx_url or not checkmarx_token:
                logger.warning("Checkmarx credentials not provided, skipping Checkmarx scan")
                self.results['checkmarx'] = {
                    'status': 'SKIPPED',
                    'reason': 'Credentials not provided'
                }
                return self.results['checkmarx']
            
            logger.info("Running Checkmarx scan...")
            
            # This would use the Checkmarx CLI or API
            # Example with CxSAST CLI:
            cmd = [
                'CxConsolePlugin',
                '-v',
                '-ProjectName', 'VERMEG-SIRH',
                '-LocationType', 'folder',
                '-LocationPath', str(self.project_root),
                '-UserName', 'admin',
                '-Password', checkmarx_token,
                '-url', checkmarx_url,
                '-ExecuteScan',
                '-generatePDFReports',
                '-ReportName', f'vermeg_sast_report_{self.timestamp}.pdf'
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
            if 'Vulnerabilities found' in result.stdout or result.returncode == 0:
                logger.info("Checkmarx scan completed")
                self.results['checkmarx'] = {
                    'status': 'SUCCESS',
                    'timestamp': datetime.now().isoformat(),
                    'output': result.stdout
                }
            else:
                self.results['checkmarx'] = {
                    'status': 'COMPLETED',
                    'timestamp': datetime.now().isoformat(),
                    'note': 'Scan completed but check server for results'
                }
            
            return self.results['checkmarx']
            
        except Exception as e:
            logger.error(f"Checkmarx execution failed: {e}")
            self.results['checkmarx'] = {
                'status': 'ERROR',
                'error': str(e)
            }
            return self.results['checkmarx']
    
    def run_bandit(self) -> Dict:
        """
        Run Bandit Python security scanner
        
        Returns:
            Scan results
        """
        try:
            logger.info("Running Bandit Python security analysis...")
            
            python_files = list(self.project_root.rglob('*.py'))
            python_files = [f for f in python_files if 'venv' not in str(f) and 'env' not in str(f)]
            
            if not python_files:
                logger.warning("No Python files found for Bandit scan")
                self.results['bandit'] = {
                    'status': 'SKIPPED',
                    'reason': 'No Python files found'
                }
                return self.results['bandit']
            
            report_file = self.output_dir / f'bandit-report-{self.timestamp}.json'
            
            cmd = [
                'bandit',
                '-r',
                'scripts',
                '-f', 'json',
                '-o', str(report_file)
            ]
            
            result = subprocess.run(cmd, cwd=str(self.project_root),
                                  capture_output=True, text=True, timeout=120)
            
            # Bandit exits with 1 if issues found, 0 if clean
            if result.returncode in [0, 1]:
                logger.info(f"Bandit analysis completed, report saved to {report_file}")
                
                # Parse results
                with open(report_file) as f:
                    bandit_results = json.load(f)
                
                self.results['bandit'] = {
                    'status': 'SUCCESS',
                    'timestamp': datetime.now().isoformat(),
                    'issues': bandit_results.get('results', []),
                    'metrics': bandit_results.get('metrics', {}),
                    'report_file': str(report_file)
                }
            else:
                logger.error(f"Bandit failed: {result.stderr}")
                self.results['bandit'] = {
                    'status': 'FAILED',
                    'error': result.stderr
                }
            
            return self.results['bandit']
            
        except Exception as e:
            logger.error(f"Bandit execution failed: {e}")
            self.results['bandit'] = {
                'status': 'ERROR',
                'error': str(e)
            }
            return self.results['bandit']
    
    def run_semgrep(self) -> Dict:
        """
        Run Semgrep semantic code analysis
        
        Returns:
            Scan results
        """
        try:
            logger.info("Running Semgrep analysis...")
            
            report_file = self.output_dir / f'semgrep-report-{self.timestamp}.json'
            
            cmd = [
                'semgrep',
                '--config=p/security-audit',
                '--config=p/owasp-top-ten',
                '-r',
                'backend,front',
                '--json',
                '-o', str(report_file),
                '--optimizations=all'
            ]
            
            result = subprocess.run(cmd, cwd=str(self.project_root),
                                  capture_output=True, text=True, timeout=300)
            
            if result.returncode in [0, 1]:
                logger.info(f"Semgrep analysis completed, report saved to {report_file}")
                
                with open(report_file) as f:
                    semgrep_results = json.load(f)
                
                self.results['semgrep'] = {
                    'status': 'SUCCESS',
                    'timestamp': datetime.now().isoformat(),
                    'issues': semgrep_results.get('results', []),
                    'report_file': str(report_file)
                }
            else:
                logger.error(f"Semgrep failed: {result.stderr}")
                self.results['semgrep'] = {
                    'status': 'FAILED',
                    'error': result.stderr
                }
            
            return self.results['semgrep']
            
        except Exception as e:
            logger.error(f"Semgrep execution failed: {e}")
            self.results['semgrep'] = {
                'status': 'ERROR',
                'error': str(e)
            }
            return self.results['semgrep']
    
    def run_spotbugs(self) -> Dict:
        """
        Run SpotBugs for Java analysis
        
        Returns:
            Scan results
        """
        try:
            logger.info("Running SpotBugs Java analysis...")
            
            # Find compiled Java classes
            class_dirs = list(self.project_root.glob('backend/*/target/classes'))
            
            if not class_dirs:
                logger.warning("No compiled Java classes found")
                self.results['spotbugs'] = {
                    'status': 'SKIPPED',
                    'reason': 'No compiled Java classes found'
                }
                return self.results['spotbugs']
            
            report_file = self.output_dir / f'spotbugs-report-{self.timestamp}.html'
            
            for class_dir in class_dirs:
                cmd = [
                    'spotbugs',
                    '-html',
                    '-output', str(report_file),
                    str(class_dir)
                ]
                
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
                
                if result.returncode in [0, 1, 2, 3]:  # SpotBugs uses different exit codes
                    logger.info(f"SpotBugs analysis completed for {class_dir.parent.name}")
            
            self.results['spotbugs'] = {
                'status': 'SUCCESS',
                'timestamp': datetime.now().isoformat(),
                'report_file': str(report_file)
            }
            
            return self.results['spotbugs']
            
        except Exception as e:
            logger.error(f"SpotBugs execution failed: {e}")
            self.results['spotbugs'] = {
                'status': 'ERROR',
                'error': str(e)
            }
            return self.results['spotbugs']
    
    def run_eslint(self) -> Dict:
        """
        Run ESLint for JavaScript/TypeScript analysis
        
        Returns:
            Scan results
        """
        try:
            logger.info("Running ESLint analysis...")
            
            report_file = self.output_dir / f'eslint-report-{self.timestamp}.json'
            
            cmd = [
                'npm',
                'run',
                'lint:security'  # Custom lint script for security
            ]
            
            # Fallback to standard eslint
            if not self._has_npm_script('lint:security'):
                cmd = [
                    'npx',
                    'eslint',
                    'front/src',
                    '--format', 'json',
                    '--output-file', str(report_file),
                    '--plugin', 'security'
                ]
            
            result = subprocess.run(cmd, cwd=str(self.project_root),
                                  capture_output=True, text=True, timeout=120)
            
            if result.returncode in [0, 1]:
                logger.info(f"ESLint analysis completed")
                
                if report_file.exists():
                    with open(report_file) as f:
                        eslint_results = json.load(f)
                    
                    self.results['eslint'] = {
                        'status': 'SUCCESS',
                        'issues': eslint_results,
                        'report_file': str(report_file),
                        'timestamp': datetime.now().isoformat()
                    }
                else:
                    self.results['eslint'] = {
                        'status': 'SUCCESS',
                        'output': result.stdout,
                        'timestamp': datetime.now().isoformat()
                    }
            else:
                logger.error(f"ESLint failed: {result.stderr}")
                self.results['eslint'] = {
                    'status': 'FAILED',
                    'error': result.stderr
                }
            
            return self.results['eslint']
            
        except Exception as e:
            logger.error(f"ESLint execution failed: {e}")
            self.results['eslint'] = {
                'status': 'ERROR',
                'error': str(e)
            }
            return self.results['eslint']
    
    def _has_npm_script(self, script_name: str) -> bool:
        """Check if npm script exists in package.json"""
        try:
            package_json = self.project_root / 'front' / 'package.json'
            with open(package_json) as f:
                data = json.load(f)
                return script_name in data.get('scripts', {})
        except:
            return False
    
    def generate_sast_report(self) -> str:
        """
        Generate comprehensive SAST report
        
        Returns:
            Path to report file
        """
        try:
            logger.info("Generating comprehensive SAST report...")
            
            report_file = self.output_dir / f'sast-report-{self.timestamp}.html'
            
            html_content = self._generate_html_report()
            
            with open(report_file, 'w') as f:
                f.write(html_content)
            
            logger.info(f"SAST report generated: {report_file}")
            
            # Also generate JSON version
            json_file = self.output_dir / f'sast-report-{self.timestamp}.json'
            with open(json_file, 'w') as f:
                json.dump(self.results, f, indent=2, default=str)
            
            logger.info(f"SAST JSON report generated: {json_file}")
            
            return str(report_file)
            
        except Exception as e:
            logger.error(f"Failed to generate SAST report: {e}")
            raise
    
    def _generate_html_report(self) -> str:
        """Generate HTML report content"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        tools_html = ""
        total_issues = 0
        
        for tool, result in self.results.items():
            status = result.get('status', 'UNKNOWN')
            status_color = {
                'SUCCESS': '#10b981',
                'FAILED': '#ef4444',
                'ERROR': '#f97316',
                'SKIPPED': '#6b7280'
            }.get(status, '#9ca3af')
            
            issues = result.get('issues', [])
            if isinstance(issues, list):
                issue_count = len(issues)
                total_issues += issue_count
            else:
                issue_count = 'N/A'
            
            tools_html += f"""
            <div class="tool-result">
                <h3>{tool.upper()}</h3>
                <p><strong>Status:</strong> <span style="background-color: {status_color}; padding: 4px 8px; border-radius: 4px; color: white;">{status}</span></p>
                <p><strong>Issues Found:</strong> {issue_count}</p>
                <p><strong>Timestamp:</strong> {result.get('timestamp', 'N/A')}</p>
                {f"<p><strong>Error:</strong> {result.get('error', '')}</p>" if result.get('error') else ""}
                {f"<p><strong>Reason:</strong> {result.get('reason', '')}</p>" if result.get('reason') else ""}
                {f"<p><a href='{result.get('report_file')}'>View Detailed Report</a></p>" if result.get('report_file') else ""}
            </div>
            """
        
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>SAST Report - VERMEG SIRH</title>
            <style>
                body {{
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
                    margin: 0;
                    padding: 20px;
                }}
                .container {{
                    max-width: 1200px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 8px;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
                    padding: 40px;
                }}
                h1 {{
                    color: #0f172a;
                    border-bottom: 3px solid #06b6d4;
                    padding-bottom: 10px;
                }}
                h2 {{
                    color: #1e293b;
                    margin-top: 30px;
                }}
                .summary {{
                    background: #f0f9ff;
                    border-left: 4px solid #06b6d4;
                    padding: 15px;
                    margin: 20px 0;
                    border-radius: 4px;
                }}
                .tool-result {{
                    border: 1px solid #e5e7eb;
                    padding: 15px;
                    margin: 15px 0;
                    border-radius: 4px;
                    background: #f9fafb;
                }}
                .tool-result h3 {{
                    margin-top: 0;
                    color: #1f2937;
                }}
                a {{
                    color: #06b6d4;
                    text-decoration: none;
                }}
                a:hover {{
                    text-decoration: underline;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🔒 Static Application Security Testing (SAST) Report</h1>
                <h2>VERMEG SIRH - Comprehensive Security Analysis</h2>
                
                <div class="summary">
                    <p><strong>Report Generated:</strong> {timestamp}</p>
                    <p><strong>Project:</strong> VERMEG SIRH</p>
                    <p><strong>Total Issues Identified:</strong> {total_issues}</p>
                    <p><strong>Tools Executed:</strong> {len(self.results)}</p>
                </div>
                
                <h2>Security Scanning Tools</h2>
                {tools_html}
                
                <h2>Recommendations</h2>
                <ul>
                    <li>Review and fix all CRITICAL and HIGH severity issues immediately</li>
                    <li>Create tickets for MEDIUM severity issues with 30-day resolution target</li>
                    <li>Track LOW severity issues and plan remediation in future sprints</li>
                    <li>Run SAST scans on every commit to catch issues early</li>
                    <li>Implement secure coding practices based on the findings</li>
                    <li>Regular training on OWASP Top 10 and secure development</li>
                </ul>
                
                <footer style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e7eb; color: #6b7280; font-size: 12px;">
                    <p>Generated by VERMEG Security Dashboard</p>
                    <p>For more information, visit: https://owasp.org/Top10/</p>
                </footer>
            </div>
        </body>
        </html>
        """
    
    def run_all_sast(self, sonar_enabled: bool = True, checkmarx_enabled: bool = False) -> Dict:
        """
        Run all configured SAST tools
        
        Args:
            sonar_enabled: Run SonarQube
            checkmarx_enabled: Run Checkmarx
        
        Returns:
            All results
        """
        logger.info("Starting comprehensive SAST scan...")
        
        if sonar_enabled:
            self.run_sonarqube()
        
        if checkmarx_enabled:
            self.run_checkmarx()
        
        self.run_bandit()
        self.run_semgrep()
        self.run_spotbugs()
        self.run_eslint()
        
        self.generate_sast_report()
        
        return self.results


if __name__ == '__main__':
    import sys
    
    orchestrator = SASTOrchestrator()
    
    if len(sys.argv) > 1:
        tool = sys.argv[1].lower()
        
        if tool == 'sonar':
            orchestrator.run_sonarqube()
        elif tool == 'bandit':
            orchestrator.run_bandit()
        elif tool == 'semgrep':
            orchestrator.run_semgrep()
        elif tool == 'eslint':
            orchestrator.run_eslint()
        elif tool == 'spotbugs':
            orchestrator.run_spotbugs()
        elif tool == 'all':
            orchestrator.run_all_sast()
        else:
            print(f"Unknown tool: {tool}")
            print("Available: sonar, bandit, semgrep, eslint, spotbugs, all")
    else:
        orchestrator.run_all_sast()
    
    # Print results
    print("\n=== SAST Results ===")
    print(json.dumps(orchestrator.results, indent=2, default=str))
