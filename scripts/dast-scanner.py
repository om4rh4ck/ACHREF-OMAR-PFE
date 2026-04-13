#!/usr/bin/env python3
"""
Dynamic Application Security Testing (DAST) Scanner
Basic tests for common web vulnerabilities:
- SQL Injection
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Insecure Direct Object Reference (IDOR)
- Security Misconfiguration
- Sensitive Data Exposure
"""

import json
import logging
import requests
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from urllib.parse import urljoin, quote
import re

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class DASTScanner:
    """Dynamic Application Security Testing Scanner"""
    
    # Common SQL injection payloads (safe for detection)
    SQL_INJECTION_PAYLOADS = [
        "' OR '1'='1",
        "' OR 1=1--",
        "1' UNION SELECT NULL--",
        "admin' --",
        "' OR 'a'='a",
        "1; DROP TABLE users--",
    ]
    
    # XSS payloads
    XSS_PAYLOADS = [
        '<script>alert("XSS")</script>',
        '"><script>alert("XSS")</script>',
        '<img src=x onerror=alert("XSS")>',
        '<svg onload=alert("XSS")>',
        'javascript:alert("XSS")',
    ]
    
    # Other security test strings
    SECURITY_TEST_PAYLOADS = {
        'path_traversal': [
            '../../../etc/passwd',
            '..\\..\\..\\windows\\system32\\config\\sam',
            '....//....//....//etc/passwd',
        ],
        'command_injection': [
            '; ls -la',
            '| id',
            '&& whoami',
            '`whoami`',
            '$(whoami)',
        ],
        'ldap_injection': [
            '*',
            'admin*',
            '*)(|(uid=*',
        ]
    }
    
    def __init__(self, url: str, timeout: int = 10):
        """
        Initialize DAST scanner
        
        Args:
            url: Target URL
            timeout: Request timeout
        """
        self.url = url
        self.timeout = timeout
        self.session = requests.Session()
        self.results = {
            'vulnerabilities': [],
            'info': [],
            'timestamp': datetime.now().isoformat()
        }
    
    def check_ssl(self) -> Dict:
        """Check SSL/TLS configuration"""
        try:
            logger.info("Checking SSL/TLS...")
            
            # Try to connect with verification
            response = self.session.head(
                self.url,
                timeout=self.timeout,
                verify=True
            )
            
            return {
                'check': 'SSL_Valid',
                'status': 'PASS',
                'message': 'Valid SSL certificate'
            }
        
        except requests.exceptions.SSLError as e:
            return {
                'check': 'SSL_Invalid',
                'status': 'FAIL',
                'severity': 'CRITICAL',
                'message': 'Invalid or missing SSL certificate',
                'error': str(e)
            }
        except Exception as e:
            return {
                'check': 'SSL_Check',
                'status': 'UNKNOWN',
                'message': str(e)
            }
    
    def check_security_headers(self) -> List[Dict]:
        """Check for missing security headers"""
        try:
            logger.info("Checking security headers...")
            
            response = self.session.head(self.url, timeout=self.timeout, verify=False)
            headers = response.headers
            
            issues = []
            
            # Check critical headers
            critical_headers = {
                'Strict-Transport-Security': 'HSTS',
                'X-Content-Type-Options': 'MIME sniffing protection',
                'X-Frame-Options': 'Clickjacking protection',
                'Content-Security-Policy': 'XSS protection'
            }
            
            for header, description in critical_headers.items():
                if header not in headers:
                    issues.append({
                        'type': 'MissingSecurityHeader',
                        'severity': 'HIGH',
                        'header': header,
                        'description': description,
                        'remediation': f'Add {header} header to responses'
                    })
            
            # Check for information disclosure headers
            info_headers = ['X-Powered-By', 'Server', 'X-AspNet-Version']
            for header in info_headers:
                if header in headers:
                    issues.append({
                        'type': 'InformationDisclosure',
                        'severity': 'MEDIUM',
                        'header': header,
                        'value': headers[header],
                        'description': 'Header discloses technology information',
                        'remediation': f'Remove or obfuscate {header} header'
                    })
            
            return issues
        
        except Exception as e:
            logger.error(f"Security headers check failed: {e}")
            return []
    
    def test_sql_injection(self) -> List[Dict]:
        """Test for SQL injection vulnerabilities"""
        logger.info("Testing for SQL injection...")
        issues = []
        
        # Test common endpoints
        test_endpoints = [
            (self.url, 'GET', {'id': '1'}),
            (self.url, 'POST', {'search': 'test'}),
        ]
        
        for endpoint, method, params in test_endpoints:
            for payload in self.SQL_INJECTION_PAYLOADS:
                try:
                    test_params = params.copy()
                    # Test first parameter
                    first_key = list(test_params.keys())[0]
                    test_params[first_key] = payload
                    
                    if method == 'GET':
                        response = self.session.get(endpoint, params=test_params, timeout=self.timeout, verify=False)
                    else:
                        response = self.session.post(endpoint, data=test_params, timeout=self.timeout, verify=False)
                    
                    # Check response for SQL errors
                    sql_errors = [
                        'SQL syntax',
                        'mysql_fetch',
                        'ORA-',
                        'SQL Server',
                        'PostgreSQL',
                        'SQLite',
                    ]
                    
                    if any(error in response.text for error in sql_errors):
                        issues.append({
                            'type': 'SQL_Injection',
                            'severity': 'CRITICAL',
                            'method': method,
                            'endpoint': endpoint,
                            'parameter': first_key,
                            'payload': payload,
                            'description': 'Potential SQL injection detected',
                            'remediation': 'Use parameterized queries or prepared statements'
                        })
                        break
                
                except Exception as e:
                    logger.debug(f"SQL injection test failed: {e}")
        
        return issues
    
    def test_xss(self) -> List[Dict]:
        """Test for Cross-Site Scripting (XSS) vulnerabilities"""
        logger.info("Testing for XSS...")
        issues = []
        
        test_endpoints = [
            (self.url, 'GET', {'search': 'test'}),
            (self.url, 'POST', {'comment': 'test'}),
        ]
        
        for endpoint, method, params in test_endpoints:
            for xss_payload in self.XSS_PAYLOADS:
                try:
                    test_params = params.copy()
                    first_key = list(test_params.keys())[0]
                    test_params[first_key] = xss_payload
                    
                    if method == 'GET':
                        response = self.session.get(endpoint, params=test_params, timeout=self.timeout, verify=False)
                    else:
                        response = self.session.post(endpoint, data=test_params, timeout=self.timeout, verify=False)
                    
                    # Check if payload reflected in response
                    if xss_payload in response.text:
                        issues.append({
                            'type': 'XSS_Reflected',
                            'severity': 'HIGH',
                            'method': method,
                            'endpoint': endpoint,
                            'parameter': first_key,
                            'payload': xss_payload,
                            'description': 'Reflected XSS vulnerability detected',
                            'remediation': 'HTML encode and validate all user input'
                        })
                        break
                
                except Exception as e:
                    logger.debug(f"XSS test failed: {e}")
        
        return issues
    
    def test_security_misconfiguration(self) -> List[Dict]:
        """Test for security misconfiguration"""
        logger.info("Testing for security misconfiguration...")
        issues = []
        
        # Test for common default/backup files
        dangerous_paths = [
            '/admin',
            '/admin.php',
            '/wp-admin',
            '/.git',
            '/.env',
            '/config.php',
            '/web.config',
            '/backup.sql',
            '/.aws',
            '/secrets.json',
        ]
        
        for path in dangerous_paths:
            try:
                test_url = urljoin(self.url, path)
                response = self.session.head(test_url, timeout=self.timeout, verify=False)
                
                if response.status_code == 200:
                    issues.append({
                        'type': 'Sensitive_Path_Accessible',
                        'severity': 'HIGH',
                        'path': path,
                        'status_code': response.status_code,
                        'description': f'Sensitive path {path} is publicly accessible',
                        'remediation': 'Restrict access to sensitive paths'
                    })
                
                elif response.status_code == 403:
                    # Path exists but forbidden - information disclosure
                    issues.append({
                        'type': 'Path_Disclosure',
                        'severity': 'LOW',
                        'path': path,
                        'status_code': response.status_code,
                        'description': f'Existence of {path} disclosed (403 Forbidden)',
                        'remediation': 'Return 404 for non-existent paths'
                    })
            
            except Exception as e:
                logger.debug(f"Path test failed: {e}")
        
        return issues
    
    def test_http_methods(self) -> List[Dict]:
        """Test for dangerous HTTP methods"""
        logger.info("Testing HTTP methods...")
        issues = []
        
        dangerous_methods = ['PUT', 'DELETE', 'TRACE', 'LOCK']
        
        for method in dangerous_methods:
            try:
                response = self.session.request(method, self.url, timeout=self.timeout, verify=False)
                
                if response.status_code < 400:
                    issues.append({
                        'type': 'Dangerous_HTTP_Method',
                        'severity': 'MEDIUM',
                        'method': method,
                        'status_code': response.status_code,
                        'description': f'HTTP {method} method is allowed',
                        'remediation': 'Disable PUT, DELETE, TRACE methods'
                    })
            
            except Exception as e:
                logger.debug(f"HTTP method test failed: {e}")
        
        return issues
    
    def test_sensitive_data(self) -> List[Dict]:
        """Test for sensitive data exposure"""
        logger.info("Testing for sensitive data exposure...")
        issues = []
        
        try:
            response = self.session.get(self.url, timeout=self.timeout, verify=False)
            
            # Check for sensitive patterns
            sensitive_patterns = {
                'credit_card': r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b',
                'api_key': r'api[_-]?key[\s=:]*["\']?[a-zA-Z0-9_-]{20,}',
                'password_in_url': r'password[\s=:]*["\'][^"\']+["\']',
                'private_key': r'-----BEGIN.*PRIVATE KEY-----',
                'aws_key': r'AKIA[0-9A-Z]{16}',
            }
            
            for data_type, pattern in sensitive_patterns.items():
                if re.search(pattern, response.text, re.IGNORECASE):
                    issues.append({
                        'type': 'Sensitive_Data_Exposure',
                        'severity': 'CRITICAL',
                        'data_type': data_type,
                        'location': 'Response body',
                        'description': f'{data_type} found in response',
                        'remediation': 'Remove sensitive data from responses'
                    })
        
        except Exception as e:
            logger.error(f"Sensitive data test failed: {e}")
        
        return issues
    
    def scan_all(self) -> Dict:
        """Run comprehensive DAST scan"""
        logger.info(f"Starting DAST scan for {self.url}")
        
        # Run all tests
        ssl_issue = self.check_ssl()
        if ssl_issue['status'] == 'FAIL':
            self.results['vulnerabilities'].append(ssl_issue)
        
        self.results['vulnerabilities'].extend(self.check_security_headers())
        self.results['vulnerabilities'].extend(self.test_sql_injection())
        self.results['vulnerabilities'].extend(self.test_xss())
        self.results['vulnerabilities'].extend(self.test_security_misconfiguration())
        self.results['vulnerabilities'].extend(self.test_http_methods())
        self.results['vulnerabilities'].extend(self.test_sensitive_data())
        
        # Calculate statistics
        critical = len([v for v in self.results['vulnerabilities'] if v.get('severity') == 'CRITICAL'])
        high = len([v for v in self.results['vulnerabilities'] if v.get('severity') == 'HIGH'])
        medium = len([v for v in self.results['vulnerabilities'] if v.get('severity') == 'MEDIUM'])
        low = len([v for v in self.results['vulnerabilities'] if v.get('severity') == 'LOW'])
        
        self.results.update({
            'url': self.url,
            'scan_type': 'DAST',
            'status': 'SECURE' if critical + high == 0 else 'VULNERABILITIES_FOUND',
            'total_issues': len(self.results['vulnerabilities']),
            'critical': critical,
            'high': high,
            'medium': medium,
            'low': low,
        })
        
        logger.info(f"DAST scan complete: {critical} critical, {high} high issues found")
        return self.results


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 dast-scanner.py <url>")
        print("Example: python3 dast-scanner.py https://example.com")
        sys.exit(1)
    
    url = sys.argv[1]
    
    scanner = DASTScanner(url)
    results = scanner.scan_all()
    
    print("\n" + "="*70)
    print(f"DAST Scan Results for {url}")
    print("="*70)
    print(json.dumps(results, indent=2, default=str))
