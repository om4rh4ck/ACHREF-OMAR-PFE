#!/usr/bin/env python3
"""
HTTP Security Headers Validator
Checks for presence and correctness of security headers
"""

import json
import logging
import requests
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from urllib.parse import urljoin

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class SecurityHeadersValidator:
    """Validates HTTP security headers"""
    
    # Required security headers and their expected values
    SECURITY_HEADERS = {
        'Strict-Transport-Security': {
            'required': True,
            'expected_pattern': 'max-age=',
            'description': 'Enforces HTTPS',
            'severity': 'CRITICAL'
        },
        'X-Content-Type-Options': {
            'required': True,
            'expected_value': 'nosniff',
            'description': 'Prevents MIME sniffing',
            'severity': 'HIGH'
        },
        'X-Frame-Options': {
            'required': True,
            'expected_values': ['DENY', 'SAMEORIGIN'],
            'description': 'Prevents clickjacking',
            'severity': 'HIGH'
        },
        'X-XSS-Protection': {
            'required': True,
            'expected_value': '1; mode=block',
            'description': 'XSS protection',
            'severity': 'MEDIUM'
        },
        'Content-Security-Policy': {
            'required': True,
            'expected_pattern': 'default-src',
            'description': 'Prevents XSS and injection attacks',
            'severity': 'CRITICAL'
        },
        'Referrer-Policy': {
            'required': True,
            'expected_values': ['no-referrer', 'strict-origin-when-cross-origin', 'same-origin'],
            'description': 'Controls referrer information',
            'severity': 'MEDIUM'
        },
        'Permissions-Policy': {
            'required': False,
            'description': 'Controls browser privileges',
            'severity': 'LOW'
        },
        'X-Powered-By': {
            'required': False,
            'should_not_exist': True,
            'description': 'Hides technology stack',
            'severity': 'LOW'
        },
        'Server': {
            'required': False,
            'should_be_generic': True,
            'description': 'Minimizes server information',
            'severity': 'LOW'
        }
    }
    
    def __init__(self, url: str, timeout: int = 10):
        """
        Initialize security headers validator
        
        Args:
            url: Target URL to test
            timeout: Request timeout
        """
        self.url = url
        self.timeout = timeout
        self.results = {}
    
    def get_headers(self) -> Optional[Dict]:
        """Fetch HTTP headers from target"""
        try:
            logger.info(f"Fetching headers from {self.url}")
            
            # Verify SSL if HTTPS
            verify_ssl = self.url.startswith('https')
            
            response = requests.head(
                self.url,
                timeout=self.timeout,
                verify=verify_ssl,
                allow_redirects=True
            )
            
            # Some servers don't respond to HEAD, try GET
            if response.status_code >= 400:
                logger.warning("HEAD request failed, trying GET")
                response = requests.get(
                    self.url,
                    timeout=self.timeout,
                    verify=verify_ssl,
                    allow_redirects=True,
                    stream=True
                )
                response.close()
            
            if response.status_code < 400:
                logger.info(f"Successfully retrieved headers (HTTP {response.status_code})")
                return dict(response.headers)
            else:
                logger.error(f"Failed to get headers: HTTP {response.status_code}")
                return None
        
        except requests.exceptions.ConnectionError as e:
            logger.error(f"Connection error: {e}")
            return None
        except requests.exceptions.Timeout:
            logger.error(f"Request timeout after {self.timeout}s")
            return None
        except Exception as e:
            logger.error(f"Failed to fetch headers: {e}")
            return None
    
    def validate_header(self, header_name: str, header_value: str, config: Dict) -> Dict:
        """Validate individual header"""
        
        result = {
            'header': header_name,
            'present': True,
            'value': header_value,
            'status': 'PASS'
        }
        
        # Check if header should not exist
        if config.get('should_not_exist'):
            result['status'] = 'FAIL'
            result['issue'] = f'{header_name} header should not be present'
            result['severity'] = config.get('severity', 'MEDIUM')
            return result
        
        # Check expected value
        if 'expected_value' in config:
            if header_value.lower() == config['expected_value'].lower():
                result['status'] = 'PASS'
            else:
                result['status'] = 'FAIL'
                result['expected'] = config['expected_value']
                result['issue'] = f'Expected: {config["expected_value"]}, Got: {header_value}'
                result['severity'] = config.get('severity', 'MEDIUM')
        
        # Check expected values (multiple options)
        elif 'expected_values' in config:
            if any(header_value.lower().startswith(v.lower()) for v in config['expected_values']):
                result['status'] = 'PASS'
            else:
                result['status'] = 'FAIL'
                result['expected'] = config['expected_values']
                result['issue'] = f'Expected one of: {config["expected_values"]}, Got: {header_value}'
                result['severity'] = config.get('severity', 'MEDIUM')
        
        # Check pattern match
        elif 'expected_pattern' in config:
            if config['expected_pattern'].lower() in header_value.lower():
                result['status'] = 'PASS'
            else:
                result['status'] = 'FAIL'
                result['issue'] = f'Expected pattern "{config["expected_pattern"]}" not found'
                result['severity'] = config.get('severity', 'MEDIUM')
        
        result['description'] = config.get('description', '')
        
        return result
    
    def analyze_csp(self, csp_header: str) -> Dict:
        """Detailed CSP analysis"""
        directives = {}
        
        for directive in csp_header.split(';'):
            directive = directive.strip()
            if not directive:
                continue
            
            parts = directive.split(None, 1)
            name = parts[0]
            value = parts[1] if len(parts) > 1 else ''
            
            directives[name] = {
                'value': value,
                'secure': name not in ['default-src', 'script-src', 'style-src'] or 'unsafe' not in value.lower()
            }
        
        return {
            'directives': directives,
            'has_default_src': 'default-src' in directives,
            'has_script_src': 'script-src' in directives,
            'unsafe_directives': [k for k, v in directives.items() if not v['secure']],
            'secure': len([k for k, v in directives.items() if not v['secure']]) == 0
        }
    
    def validate_all(self) -> Dict:
        """Run comprehensive security headers validation"""
        logger.info(f"Starting security headers validation for {self.url}")
        
        headers = self.get_headers()
        if not headers:
            return {
                'url': self.url,
                'status': 'ERROR',
                'message': 'Could not connect to target',
                'timestamp': datetime.now().isoformat()
            }
        
        # Validate each security header
        validation_results = []
        missing_headers = []
        
        for header_name, config in self.SECURITY_HEADERS.items():
            header_value = None
            found = False
            
            # Case-insensitive header search
            for key, value in headers.items():
                if key.lower() == header_name.lower():
                    header_value = value
                    found = True
                    break
            
            if found:
                result = self.validate_header(header_name, header_value, config)
                validation_results.append(result)
                
                # Special analysis for CSP
                if header_name == 'Content-Security-Policy':
                    result['csp_analysis'] = self.analyze_csp(header_value)
            
            elif config.get('required'):
                missing_headers.append({
                    'header': header_name,
                    'present': False,
                    'status': 'FAIL',
                    'issue': 'Required header missing',
                    'severity': config.get('severity', 'MEDIUM'),
                    'description': config.get('description', '')
                })
                validation_results.append(missing_headers[-1])
            
            else:
                validation_results.append({
                    'header': header_name,
                    'present': False,
                    'status': 'INFO',
                    'description': config.get('description', '')
                })
        
        # Check for extra headers that reveal technology
        dangerous_headers = ['X-AspNet-Version', 'X-AspNetMvc-Version', 'X-Runtime-Version']
        extra_issues = []
        
        for dangerous in dangerous_headers:
            for header_key in headers.keys():
                if header_key.lower() == dangerous.lower():
                    extra_issues.append({
                        'header': header_key,
                        'value': headers[header_key],
                        'issue': 'Header reveals technology information',
                        'severity': 'MEDIUM'
                    })
        
        # Calculate score
        pass_count = len([r for r in validation_results if r['status'] == 'PASS'])
        fail_count = len([r for r in validation_results if r['status'] == 'FAIL'])
        total = len(validation_results)
        score = (pass_count / total * 100) if total > 0 else 0
        
        self.results = {
            'url': self.url,
            'status': 'SECURE' if fail_count == 0 else 'WARNINGS',
            'score': round(score, 1),
            'passed': pass_count,
            'failed': fail_count,
            'total_checks': total,
            'validation_results': validation_results,
            'extra_issues': extra_issues,
            'timestamp': datetime.now().isoformat()
        }
        
        logger.info(f"Security headers validation complete: {pass_count}/{total} passed")
        return self.results


def validate_multiple_urls(urls: List[str]) -> Dict:
    """Validate security headers for multiple URLs"""
    results = {}
    
    for url in urls:
        logger.info(f"Validating {url}")
        validator = SecurityHeadersValidator(url)
        results[url] = validator.validate_all()
    
    return results


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 security-headers-validator.py <url>")
        print("Example: python3 security-headers-validator.py https://example.com")
        sys.exit(1)
    
    url = sys.argv[1]
    
    validator = SecurityHeadersValidator(url)
    results = validator.validate_all()
    
    print("\n" + "="*70)
    print(f"Security Headers Validation Results for {url}")
    print("="*70)
    print(json.dumps(results, indent=2, default=str))
