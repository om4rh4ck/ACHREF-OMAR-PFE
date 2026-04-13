#!/usr/bin/env python3
"""
Vault Secret Management and Rotation System
Handles secure credential storage, retrieval, and automatic rotation
"""

import os
import json
import logging
import hashlib
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, Dict, Any
import hvac
import requests
from requests.exceptions import RequestException

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class VaultSecretManager:
    """Manages secrets using HashiCorp Vault"""
    
    def __init__(self, vault_addr: str = None, token: str = None, role_id: str = None, secret_id: str = None):
        """
        Initialize Vault client
        
        Args:
            vault_addr: Vault server address (default: env var VAULT_ADDR)
            token: Vault token for direct auth (default: env var VAULT_TOKEN)
            role_id: AppRole role-id for app auth (default: env var VAULT_ROLE_ID)
            secret_id: AppRole secret-id for app auth (default: env var VAULT_SECRET_ID)
        """
        self.vault_addr = vault_addr or os.getenv('VAULT_ADDR', 'http://localhost:8200')
        self.client = hvac.Client(url=self.vault_addr)
        
        # Authenticate based on provided credentials
        if token:
            self.client.token = token
        elif role_id and secret_id:
            self._authenticate_approle(role_id, secret_id)
        else:
            # Try environment variables
            token = os.getenv('VAULT_TOKEN')
            role_id = os.getenv('VAULT_ROLE_ID')
            secret_id = os.getenv('VAULT_SECRET_ID')
            
            if token:
                self.client.token = token
            elif role_id and secret_id:
                self._authenticate_approle(role_id, secret_id)
            else:
                raise ValueError("Must provide token or (role_id, secret_id) for authentication")
    
    def _authenticate_approle(self, role_id: str, secret_id: str):
        """Authenticate using AppRole"""
        logger.info("Authenticating with AppRole...")
        self.client.auth.approle.login(role_id=role_id, secret_id=secret_id)
        logger.info("AppRole authentication successful")
    
    def get_secret(self, path: str, key: str = None) -> Any:
        """
        Retrieve a secret from Vault
        
        Args:
            path: Path to secret (e.g., 'secret/data/cicd/database')
            key: Specific key within secret (optional)
        
        Returns:
            Secret value or entire secret dict
        """
        try:
            response = self.client.secrets.kv.v2.read_secret_version(path=path.replace('secret/data/', ''))
            data = response['data']['data']
            
            if key:
                return data.get(key)
            return data
        except Exception as e:
            logger.error(f"Failed to retrieve secret from {path}: {e}")
            raise
    
    def put_secret(self, path: str, data: Dict[str, Any], metadata: Dict = None):
        """
        Store a secret in Vault
        
        Args:
            path: Path to secret
            data: Secret data (dict)
            metadata: Optional metadata
        """
        try:
            self.client.secrets.kv.v2.create_or_update_secret(
                path=path.replace('secret/data/', ''),
                secret_data=data
            )
            logger.info(f"Secret stored at {path}")
        except Exception as e:
            logger.error(f"Failed to store secret at {path}: {e}")
            raise
    
    def delete_secret(self, path: str):
        """Delete a secret from Vault"""
        try:
            self.client.secrets.kv.v2.delete_secret_version(path=path.replace('secret/data/', ''))
            logger.info(f"Secret deleted from {path}")
        except Exception as e:
            logger.error(f"Failed to delete secret at {path}: {e}")
            raise
    
    def list_secrets(self, path: str) -> list:
        """List all secrets at given path"""
        try:
            response = self.client.secrets.kv.v2.list_secrets(path=path.replace('secret/data/', ''))
            return response['data']['keys']
        except Exception as e:
            logger.error(f"Failed to list secrets at {path}: {e}")
            raise
    
    def rotate_database_password(self, role_name: str) -> Dict[str, str]:
        """
        Rotate database password using Vault's database secret engine
        
        Args:
            role_name: Database role name
        
        Returns:
            New credentials dict
        """
        try:
            response = self.client.secrets.database.generate_credentials(role_name=role_name)
            credentials = response['data']
            logger.info(f"Database password rotated for role {role_name}")
            return credentials
        except Exception as e:
            logger.error(f"Failed to rotate password for {role_name}: {e}")
            raise


class GitHubSecretsManager:
    """Manages GitHub repository secrets"""
    
    def __init__(self, github_token: str = None, repo: str = None):
        """
        Initialize GitHub secrets manager
        
        Args:
            github_token: GitHub personal access token (default: env var GITHUB_TOKEN)
            repo: Repository in format 'owner/repo' (default: env var GITHUB_REPO)
        """
        self.github_token = github_token or os.getenv('GITHUB_TOKEN')
        self.repo = repo or os.getenv('GITHUB_REPO')
        self.base_url = f"https://api.github.com/repos/{self.repo}"
        
        if not self.github_token or not self.repo:
            raise ValueError("GitHub token and repo must be provided")
        
        self.headers = {
            'Authorization': f'token {self.github_token}',
            'Accept': 'application/vnd.github.v3+json'
        }
    
    def get_secret(self, secret_name: str) -> Optional[str]:
        """Get secret value from GitHub"""
        try:
            url = f"{self.base_url}/actions/secrets/{secret_name}"
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json().get('value')
        except RequestException as e:
            logger.error(f"Failed to get GitHub secret {secret_name}: {e}")
            return None
    
    def create_or_update_secret(self, secret_name: str, secret_value: str):
        """Create or update a GitHub secret"""
        try:
            # Get public key for encryption
            url = f"{self.base_url}/actions/secrets/public-key"
            key_response = requests.get(url, headers=self.headers)
            key_response.raise_for_status()
            public_key_data = key_response.json()
            
            # Encrypt secret using public key
            from nacl import pwhash, utils, secret
            import base64
            
            public_key = public_key_data['key']
            key_id = public_key_data['key_id']
            
            # Encrypt the secret
            sealed_box = secret.SecretBox(public_key.encode())
            encrypted = sealed_box.encrypt(secret_value.encode())
            encoded = base64.b64encode(encrypted.ciphertext).decode()
            
            # Create/update secret
            url = f"{self.base_url}/actions/secrets/{secret_name}"
            payload = {
                'encrypted_value': encoded,
                'key_id': key_id
            }
            response = requests.put(url, json=payload, headers=self.headers)
            response.raise_for_status()
            logger.info(f"GitHub secret {secret_name} created/updated")
        except Exception as e:
            logger.error(f"Failed to create/update GitHub secret {secret_name}: {e}")
            raise
    
    def delete_secret(self, secret_name: str):
        """Delete a GitHub secret"""
        try:
            url = f"{self.base_url}/actions/secrets/{secret_name}"
            response = requests.delete(url, headers=self.headers)
            response.raise_for_status()
            logger.info(f"GitHub secret {secret_name} deleted")
        except RequestException as e:
            logger.error(f"Failed to delete GitHub secret {secret_name}: {e}")
            raise
    
    def list_secrets(self) -> list:
        """List all secrets"""
        try:
            url = f"{self.base_url}/actions/secrets"
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return [s['name'] for s in response.json().get('secrets', [])]
        except RequestException as e:
            logger.error(f"Failed to list GitHub secrets: {e}")
            return []


class CredentialRotationManager:
    """Manages automatic credential rotation"""
    
    def __init__(self, vault_manager: VaultSecretManager):
        """Initialize rotation manager"""
        self.vault = vault_manager
        self.rotation_log = Path('/var/log/credential-rotation.log')
    
    def rotate_api_keys(self, service_name: str, rotation_interval_days: int = 90):
        """Rotate API keys for a service"""
        try:
            logger.info(f"Rotating API keys for {service_name}...")
            
            # Get current keys
            api_path = f"secret/data/cicd/{service_name}-api-keys"
            current_keys = self.vault.get_secret(api_path)
            
            # Generate new keys (this would call service-specific APIs)
            # Example: call Snyk API to rotate tokens
            new_keys = self._generate_new_api_keys(service_name)
            
            # Store old keys as backup
            backup_path = f"secret/data/cicd/{service_name}-api-keys-backup"
            self.vault.put_secret(backup_path, {
                **current_keys,
                'rotated_at': datetime.now().isoformat(),
                'backup_until': (datetime.now() + timedelta(days=30)).isoformat()
            })
            
            # Update with new keys
            self.vault.put_secret(api_path, {
                **new_keys,
                'rotated_at': datetime.now().isoformat(),
                'rotation_interval_days': rotation_interval_days
            })
            
            self._log_rotation(f"{service_name}-api-keys", "SUCCESS")
            logger.info(f"Successfully rotated API keys for {service_name}")
            
        except Exception as e:
            self._log_rotation(f"{service_name}-api-keys", f"FAILED: {e}")
            logger.error(f"Failed to rotate API keys for {service_name}: {e}")
            raise
    
    def rotate_database_passwords(self):
        """Rotate all database passwords"""
        try:
            logger.info("Rotating database passwords...")
            
            roles = ['application_user', 'ci_user', 'readonly_user']
            
            for role in roles:
                credentials = self.vault.rotate_database_password(role)
                
                # Update in secret storage
                db_path = f"secret/data/application/db-{role}"
                self.vault.put_secret(db_path, {
                    'username': credentials['username'],
                    'password': credentials['password'],
                    'rotated_at': datetime.now().isoformat()
                })
                
                self._log_rotation(f"db-{role}", "SUCCESS")
            
            logger.info("Successfully rotated all database passwords")
            
        except Exception as e:
            self._log_rotation("database-passwords", f"FAILED: {e}")
            logger.error(f"Failed to rotate database passwords: {e}")
            raise
    
    def rotate_ssh_keys(self, host: str):
        """Rotate SSH keys for a host"""
        try:
            logger.info(f"Rotating SSH keys for {host}...")
            
            # Generate new key pair
            from cryptography.hazmat.primitives import serialization
            from cryptography.hazmat.primitives.asymmetric import rsa
            from cryptography.hazmat.backends import default_backend
            
            private_key = rsa.generate_private_key(
                public_exponent=65537,
                key_size=4096,
                backend=default_backend()
            )
            
            private_pem = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.OpenSSH,
                encryption_algorithm=serialization.NoEncryption()
            ).decode()
            
            public_pem = private_key.public_key().public_bytes(
                encoding=serialization.Encoding.OpenSSH,
                format=serialization.PublicFormat.OpenSSH
            ).decode()
            
            # Store in Vault
            ssh_path = f"secret/data/cicd/ssh-{host}"
            self.vault.put_secret(ssh_path, {
                'private_key': private_pem,
                'public_key': public_pem,
                'host': host,
                'rotated_at': datetime.now().isoformat()
            })
            
            self._log_rotation(f"ssh-{host}", "SUCCESS")
            logger.info(f"Successfully rotated SSH keys for {host}")
            
        except Exception as e:
            self._log_rotation(f"ssh-{host}", f"FAILED: {e}")
            logger.error(f"Failed to rotate SSH keys for {host}: {e}")
            raise
    
    def _generate_new_api_keys(self, service_name: str) -> Dict[str, str]:
        """Generate new API keys for a service"""
        import secrets
        
        if service_name.lower() == 'snyk':
            return {
                'snyk_token': f"snyk_{secrets.token_hex(32)}",
                'generated_at': datetime.now().isoformat()
            }
        elif service_name.lower() == 'sonar':
            return {
                'sonar_token': f"squ_{secrets.token_hex(32)}",
                'generated_at': datetime.now().isoformat()
            }
        elif service_name.lower() == 'nvd':
            return {
                'nvd_api_key': secrets.token_hex(32),
                'generated_at': datetime.now().isoformat()
            }
        else:
            return {
                'api_key': secrets.token_hex(32),
                'generated_at': datetime.now().isoformat()
            }
    
    def _log_rotation(self, credential_name: str, status: str):
        """Log rotation event"""
        log_entry = f"[{datetime.now().isoformat()}] {credential_name}: {status}\n"
        try:
            with open(self.rotation_log, 'a') as f:
                f.write(log_entry)
        except Exception as e:
            logger.warning(f"Could not write to rotation log: {e}")
    
    def check_expiring_credentials(self, expiry_days: int = 30) -> Dict[str, list]:
        """Check for credentials expiring soon"""
        expiring = {}
        try:
            secrets_list = self.vault.list_secrets('secret/data/cicd')
            expiry_threshold = datetime.now() + timedelta(days=expiry_days)
            
            for secret_path in secrets_list:
                try:
                    secret_data = self.vault.get_secret(f"secret/data/cicd/{secret_path}")
                    
                    if isinstance(secret_data, dict) and 'rotated_at' in secret_data:
                        rotated_at = datetime.fromisoformat(secret_data['rotated_at'])
                        interval = secret_data.get('rotation_interval_days', 90)
                        expiry_date = rotated_at + timedelta(days=interval)
                        
                        if expiry_date < expiry_threshold:
                            if 'expiring_soon' not in expiring:
                                expiring['expiring_soon'] = []
                            expiring['expiring_soon'].append({
                                'name': secret_path,
                                'expiry_date': expiry_date.isoformat(),
                                'days_remaining': (expiry_date - datetime.now()).days
                            })
                except Exception as e:
                    logger.warning(f"Could not check rotation date for {secret_path}: {e}")
            
            logger.info(f"Found {len(expiring.get('expiring_soon', []))} credentials expiring soon")
            return expiring
            
        except Exception as e:
            logger.error(f"Failed to check expiring credentials: {e}")
            return {}


def sync_secrets_vault_to_github(vault_manager: VaultSecretManager, github_manager: GitHubSecretsManager):
    """Sync secrets from Vault to GitHub"""
    try:
        logger.info("Syncing secrets from Vault to GitHub...")
        
        # Sync CICD secrets
        cicd_secrets = vault_manager.list_secrets('secret/data/cicd')
        
        for secret_name in cicd_secrets:
            try:
                secret_data = vault_manager.get_secret(f"secret/data/cicd/{secret_name}")
                
                if isinstance(secret_data, dict):
                    # Convert dict to JSON string
                    secret_value = json.dumps(secret_data)
                else:
                    secret_value = str(secret_data)
                
                # Create GitHub secret (uppercase, replace hyphens)
                github_secret_name = f"VAULT_{secret_name.upper().replace('-', '_')}"
                github_manager.create_or_update_secret(github_secret_name, secret_value)
                
            except Exception as e:
                logger.warning(f"Failed to sync {secret_name}: {e}")
        
        logger.info("Secrets synced successfully")
        
    except Exception as e:
        logger.error(f"Failed to sync secrets: {e}")
        raise


if __name__ == '__main__':
    import sys
    
    command = sys.argv[1] if len(sys.argv) > 1 else 'list'
    
    try:
        # Initialize managers
        vault_mgr = VaultSecretManager()
        
        if command == 'list':
            secrets = vault_mgr.list_secrets('secret/data/cicd')
            print("Secrets in Vault:")
            for secret in secrets:
                print(f"  - {secret}")
        
        elif command == 'rotate-all':
            rotation_mgr = CredentialRotationManager(vault_mgr)
            rotation_mgr.rotate_api_keys('snyk')
            rotation_mgr.rotate_api_keys('sonar')
            rotation_mgr.rotate_database_passwords()
            
        elif command == 'check-expiry':
            rotation_mgr = CredentialRotationManager(vault_mgr)
            expiring = rotation_mgr.check_expiring_credentials()
            print(json.dumps(expiring, indent=2))
        
        elif command == 'rotate-db':
            rotation_mgr = CredentialRotationManager(vault_mgr)
            rotation_mgr.rotate_database_passwords()
        
        elif command == 'sync-github':
            github_token = os.getenv('GITHUB_TOKEN')
            github_repo = os.getenv('GITHUB_REPO')
            if github_token and github_repo:
                github_mgr = GitHubSecretsManager(github_token, github_repo)
                sync_secrets_vault_to_github(vault_mgr, github_mgr)
            else:
                logger.error("GITHUB_TOKEN and GITHUB_REPO environment variables required")
        
        else:
            print(f"Unknown command: {command}")
            print("Available commands: list, rotate-all, rotate-db, check-expiry, sync-github")
    
    except Exception as e:
        logger.error(f"Error: {e}")
        sys.exit(1)
