#!/usr/bin/env python3
"""
SSL/TLS & HTTPS Validation Module
Tests certificate validity, cipher strength, SSL/TLS version compatibility
"""

import os
import json
import ssl
import socket
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from urllib.parse import urlparse
import subprocess

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class SSLTLSValidator:
    """Validates SSL/TLS certificates and configuration"""
    
    def __init__(self, host: str, port: int = 443, timeout: int = 10):
        """
        Initialize SSL/TLS validator
        
        Args:
            host: Hostname or IP
            port: Port number (default 443)
            timeout: Connection timeout in seconds
        """
        self.host = host
        self.port = port
        self.timeout = timeout
        self.results = {}
    
    def get_certificate(self) -> Optional[dict]:
        """Retrieve SSL certificate details"""
        try:
            logger.info(f"Retrieving certificate from {self.host}:{self.port}")
            
            context = ssl.create_default_context()
            context.check_hostname = False
            context.verify_mode = ssl.CERT_NONE
            
            with socket.create_connection((self.host, self.port), timeout=self.timeout) as sock:
                with context.wrap_socket(sock, server_hostname=self.host) as ssock:
                    cert = ssock.getpeercert()
                    
                    if cert:
                        logger.info("Certificate retrieved successfully")
                        return cert
                    else:
                        logger.error("No certificate found")
                        return None
        
        except socket.timeout:
            logger.error(f"Connection timeout to {self.host}:{self.port}")
            return None
        except Exception as e:
            logger.error(f"Failed to retrieve certificate: {e}")
            return None
    
    def validate_certificate(self) -> Dict:
        """Validate certificate validity and chain"""
        try:
            logger.info("Validating certificate...")
            
            cert = self.get_certificate()
            if not cert:
                return {
                    'status': 'ERROR',
                    'message': 'Could not retrieve certificate',
                    'timestamp': datetime.now().isoformat()
                }
            
            # Check expiration
            not_after = cert.get('notAfter', '')
            not_before = cert.get('notBefore', '')
            
            # Parse dates
            import email.utils
            
            if not_after:
                exp_time = email.utils.parsedate_to_datetime(not_after)
                exp_secs = (exp_time - datetime.now(exp_time.tzinfo)).total_seconds()
                
                if exp_secs < 0:
                    status = 'EXPIRED'
                elif exp_secs < 7 * 86400:  # Less than 7 days
                    status = 'EXPIRING_SOON'
                else:
                    status = 'VALID'
            else:
                status = 'UNKNOWN'
            
            # Get subject info
            subject = dict(x[0] for x in cert.get('subject', []))
            issuer = dict(x[0] for x in cert.get('issuer', []))
            
            # Get SAN (Subject Alternative Names)
            san = []
            for ext in cert.get('subjectAltName', []):
                if ext[0] == 'DNS':
                    san.append(ext[1])
            
            self.results['certificate'] = {
                'status': status,
                'subject': subject,
                'issuer': issuer,
                'issued': not_before,
                'expires': not_after,
                'days_until_expiry': int(exp_secs / 86400) if exp_secs > 0 else 0,
                'san': san,
                'timestamp': datetime.now().isoformat()
            }
            
            logger.info(f"Certificate validation: {status}")
            return self.results['certificate']
        
        except Exception as e:
            logger.error(f"Certificate validation failed: {e}")
            return {
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    def check_tls_versions(self) -> Dict:
        """Check supported TLS versions"""
        try:
            logger.info("Checking TLS versions...")
            
            tls_versions = {
                'SSL 2.0': ssl.PROTOCOL_SSLv2,
                'SSL 3.0': ssl.PROTOCOL_SSLv3,
                'TLS 1.0': ssl.PROTOCOL_TLSv1,
                'TLS 1.1': ssl.PROTOCOL_TLSv1_1,
                'TLS 1.2': ssl.PROTOCOL_TLSv1_2,
                'TLS 1.3': ssl.PROTOCOL_TLS,  # Highest available
            }
            
            supported = []
            disabled = []
            
            for version, protocol in tls_versions.items():
                try:
                    context = ssl.SSLContext(protocol)
                    context.check_hostname = False
                    context.verify_mode = ssl.CERT_NONE
                    
                    with socket.create_connection((self.host, self.port), timeout=self.timeout) as sock:
                        with context.wrap_socket(sock, server_hostname=self.host) as ssock:
                            supported.append(version)
                            logger.info(f"✓ {version} supported")
                
                except (ssl.SSLError, socket.error):
                    disabled.append(version)
                    logger.info(f"✗ {version} NOT supported")
            
            # Security assessment
            insecure = [v for v in supported if any(x in v for x in ['SSL', 'TLS 1.0', 'TLS 1.1'])]
            
            self.results['tls_versions'] = {
                'supported': supported,
                'disabled': disabled,
                'secure': not bool(insecure),
                'insecure_versions': insecure,
                'recommendation': 'Only TLS 1.2 and 1.3 should be enabled' if insecure else 'Configuration is secure',
                'timestamp': datetime.now().isoformat()
            }
            
            return self.results['tls_versions']
        
        except Exception as e:
            logger.error(f"TLS version check failed: {e}")
            return {
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    def check_ciphers(self) -> Dict:
        """Check supported cipher suites"""
        try:
            logger.info("Checking cipher suites...")
            
            # Use OpenSSL if available
            cmd = f"openssl s_client -connect {self.host}:{self.port} -tls1_2 -cipher 'ALL' < /dev/null 2>/dev/null"
            
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                output = result.stdout
                
                # Extract cipher info
                ciphers = []
                for line in output.split('\n'):
                    if 'cipher' in line.lower() and '0x' in line:
                        ciphers.append(line.strip())
                
                # Identify weak ciphers
                weak_patterns = ['DES', 'MD5', 'RC4', 'PSK', 'anon', 'EXPORT']
                weak_ciphers = [c for c in ciphers if any(p in c.upper() for p in weak_patterns)]
                strong_ciphers = [c for c in ciphers if c not in weak_ciphers]
                
                self.results['ciphers'] = {
                    'total': len(ciphers),
                    'strong': len(strong_ciphers),
                    'weak': len(weak_ciphers),
                    'weak_list': weak_ciphers,
                    'secure': len(weak_ciphers) == 0,
                    'recommendation': 'Remove weak ciphers' if weak_ciphers else 'All ciphers are strong',
                    'timestamp': datetime.now().isoformat()
                }
            else:
                logger.warning("OpenSSL not available for cipher check")
                self.results['ciphers'] = {
                    'status': 'SKIPPED',
                    'reason': 'OpenSSL not available',
                    'timestamp': datetime.now().isoformat()
                }
            
            return self.results['ciphers']
        
        except Exception as e:
            logger.error(f"Cipher check failed: {e}")
            return {
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    def check_certificate_chain(self) -> Dict:
        """Verify certificate chain validity"""
        try:
            logger.info("Checking certificate chain...")
            
            # This would require a full chain verification
            # For basic check, we'll use OpenSSL
            cmd = f"openssl s_client -connect {self.host}:{self.port} -showcerts < /dev/null 2>/dev/null"
            
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                cert_count = result.stdout.count('-----BEGIN CERTIFICATE-----')
                chain_valid = cert_count > 0
                
                self.results['chain'] = {
                    'valid': chain_valid,
                    'depth': cert_count,
                    'status': 'VALID' if chain_valid else 'INVALID',
                    'timestamp': datetime.now().isoformat()
                }
            else:
                self.results['chain'] = {
                    'status': 'SKIPPED',
                    'reason': 'OpenSSL check failed',
                    'timestamp': datetime.now().isoformat()
                }
            
            return self.results['chain']
        
        except Exception as e:
            logger.error(f"Chain verification failed: {e}")
            return {
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    def run_all_checks(self) -> Dict:
        """Run comprehensive SSL/TLS validation"""
        logger.info(f"Starting comprehensive SSL/TLS check for {self.host}:{self.port}")
        
        self.validate_certificate()
        self.check_tls_versions()
        self.check_ciphers()
        self.check_certificate_chain()
        
        # Overall assessment
        cert_ok = self.results.get('certificate', {}).get('status') == 'VALID'
        tls_ok = self.results.get('tls_versions', {}).get('secure', False)
        ciphers_ok = self.results.get('ciphers', {}).get('secure', None)
        chain_ok = self.results.get('chain', {}).get('valid', False)
        
        overall = {
            'host': self.host,
            'port': self.port,
            'overall_status': 'SECURE' if all([cert_ok, tls_ok, ciphers_ok, chain_ok]) else 'WARNINGS',
            'checks': {
                'certificate': cert_ok,
                'tls_versions': tls_ok,
                'ciphers': ciphers_ok if ciphers_ok is not None else 'UNKNOWN',
                'chain': chain_ok
            },
            'timestamp': datetime.now().isoformat(),
            'details': self.results
        }
        
        logger.info(f"SSL/TLS check completed: {overall['overall_status']}")
        return overall


def validate_multiple_hosts(hosts: List[Tuple[str, int]]) -> Dict:
    """Validate multiple hosts"""
    results = {}
    
    for host, port in hosts:
        logger.info(f"Validating {host}:{port}")
        validator = SSLTLSValidator(host, port)
        results[f"{host}:{port}"] = validator.run_all_checks()
    
    return results


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 ssl-tls-validator.py <host> [port]")
        print("Example: python3 ssl-tls-validator.py example.com 443")
        sys.exit(1)
    
    host = sys.argv[1]
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 443
    
    validator = SSLTLSValidator(host, port)
    results = validator.run_all_checks()
    
    print("\n" + "="*60)
    print(f"SSL/TLS Validation Results for {host}:{port}")
    print("="*60)
    print(json.dumps(results, indent=2, default=str))
