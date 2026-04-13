#!/bin/bash

# HashiCorp Vault Initialization and Secret Setup
# This script initializes Vault and configures secret engines for VERMEG SIRH

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
VAULT_TOKEN_FILE="${VAULT_TOKEN_FILE:-.vault-token}"
VAULT_UNSEAL_FILE="${VAULT_UNSEAL_FILE:-.vault-keys}"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Vault is running
check_vault() {
    log_info "Checking Vault status at $VAULT_ADDR..."
    if ! curl -s "$VAULT_ADDR/v1/sys/health" > /dev/null; then
        log_error "Vault is not running at $VAULT_ADDR"
        exit 1
    fi
    log_success "Vault is running"
}

# Initialize Vault
init_vault() {
    log_info "Initializing Vault..."
    
    if [ -f "$VAULT_UNSEAL_FILE" ]; then
        log_warn "Vault already appears to be initialized (keys file exists)"
        return
    fi
    
    INIT_RESPONSE=$(curl -s -X POST \
        "$VAULT_ADDR/v1/sys/init" \
        -d '{
            "secret_shares": 5,
            "secret_threshold": 3
        }')
    
    echo "$INIT_RESPONSE" | jq . > "$VAULT_UNSEAL_FILE"
    
    ROOT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r '.root_token')
    echo "$ROOT_TOKEN" > "$VAULT_TOKEN_FILE"
    
    log_success "Vault initialized"
    log_warn "Unseal keys saved to $VAULT_UNSEAL_FILE"
    log_warn "Root token saved to $VAULT_TOKEN_FILE"
    log_warn "SECURE THESE FILES AND STORE IN A SAFE LOCATION!"
}

# Unseal Vault
unseal_vault() {
    log_info "Unsealing Vault..."
    
    if [ ! -f "$VAULT_UNSEAL_FILE" ]; then
        log_error "Unseal keys not found. Initialize Vault first."
        exit 1
    fi
    
    UNSEAL_KEYS=$(jq -r '.keys[]' "$VAULT_UNSEAL_FILE")
    COUNTER=0
    
    for KEY in $UNSEAL_KEYS; do
        if [ $COUNTER -ge 3 ]; then
            break
        fi
        
        curl -s -X POST \
            "$VAULT_ADDR/v1/sys/unseal" \
            -d "{\"key\": \"$KEY\"}" > /dev/null
        
        COUNTER=$((COUNTER + 1))
    done
    
    log_success "Vault unsealed"
}

# Setup secret engines
setup_secret_engines() {
    log_info "Setting up secret engines..."
    
    local TOKEN=$(cat "$VAULT_TOKEN_FILE")
    
    # Enable KV v2 secret engine
    log_info "Enabling KV v2 secret engine..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/sys/mounts/secret" \
        -d '{
            "type": "kv",
            "version": 2
        }' || log_warn "KV engine might already be enabled"
    
    # Enable database secret engine for credential rotation
    log_info "Enabling database secret engine..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/sys/mounts/database" \
        -d '{"type": "database"}' || log_warn "Database engine might already be enabled"
    
    # Enable SSH secret engine
    log_info "Enabling SSH secret engine..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/sys/mounts/ssh" \
        -d '{"type": "ssh"}' || log_warn "SSH engine might already be enabled"
    
    # Enable PKI secret engine for certificates
    log_info "Enabling PKI secret engine..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/sys/mounts/pki" \
        -d '{"type": "pki", "config": {"max_lease_ttl": "87600h"}}' || log_warn "PKI engine might already be enabled"
    
    log_success "Secret engines configured"
}

# Setup authentication policies
setup_auth_policies() {
    log_info "Setting up authentication policies..."
    
    local TOKEN=$(cat "$VAULT_TOKEN_FILE")
    
    # Create CI/CD policy
    log_info "Creating CI/CD policy..."
    curl -s -X PUT \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/sys/policies/acl/cicd" \
        -d '{
            "policy": "path \"secret/data/cicd/*\" {\n  capabilities = [\"read\", \"list\"]\n}\npath \"secret/metadata/cicd/*\" {\n  capabilities = [\"read\", \"list\"]\n}"
        }' && log_success "CI/CD policy created" || log_warn "Could not create CI/CD policy"
    
    # Create application policy
    log_info "Creating application policy..."
    curl -s -X PUT \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/sys/policies/acl/application" \
        -d '{
            "policy": "path \"secret/data/application/*\" {\n  capabilities = [\"read\", \"list\"]\n}\npath \"secret/metadata/application/*\" {\n  capabilities = [\"read\", \"list\"]\n}\npath \"database/creds/*\" {\n  capabilities = [\"read\"]\n}"
        }' && log_success "Application policy created" || log_warn "Could not create application policy"
}

# Create service accounts and policies
create_service_accounts() {
    log_info "Creating service accounts..."
    
    local TOKEN=$(cat "$VAULT_TOKEN_FILE")
    
    # Enable AppRole authentication
    log_info "Enabling AppRole authentication..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/sys/auth/approle" \
        -d '{"type": "approle"}' && log_success "AppRole enabled" || log_warn "AppRole might already be enabled"
    
    # Create CI/CD AppRole
    log_info "Creating CI/CD AppRole..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/auth/approle/role/cicd-role" \
        -d '{
            "bind_secret_id": true,
            "secret_id_ttl": "24h",
            "token_ttl": "1h",
            "token_max_ttl": "4h",
            "policies": "cicd"
        }' && log_success "CI/CD AppRole created" || log_warn "CI/CD AppRole might already exist"
}

# Seed example secrets
seed_example_secrets() {
    log_info "Seeding example secrets..."
    
    local TOKEN=$(cat "$VAULT_TOKEN_FILE")
    
    # Database credentials
    log_info "Adding database credentials..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/secret/data/cicd/database" \
        -d '{
            "data": {
                "username": "vault_user",
                "password": "changeme_vault_password",
                "host": "postgres",
                "port": "5432",
                "database": "vermeg_sirh"
            }
        }' && log_success "Database credentials added" || log_warn "Database credentials might already exist"
    
    # API Keys
    log_info "Adding API keys..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/secret/data/cicd/api-keys" \
        -d '{
            "data": {
                "sonar_token": "changeme_sonar_token",
                "snyk_token": "changeme_snyk_token",
                "nvd_api_key": "changeme_nvd_api_key"
            }
        }' && log_success "API keys added" || log_warn "API keys might already exist"
    
    # OAuth tokens
    log_info "Adding OAuth tokens..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/secret/data/cicd/oauth" \
        -d '{
            "data": {
                "github_token": "changeme_github_token",
                "dockerhub_username": "changeme_dockerhub_username",
                "dockerhub_password": "changeme_dockerhub_password"
            }
        }' && log_success "OAuth tokens added" || log_warn "OAuth tokens might already exist"
    
    # SSH Keys
    log_info "Adding SSH keys..."
    curl -s -X POST \
        -H "X-Vault-Token: $TOKEN" \
        "$VAULT_ADDR/v1/secret/data/cicd/ssh" \
        -d '{
            "data": {
                "deploy_key": "changeme_deploy_ssh_key",
                "deploy_user": "ci-deploy",
                "deploy_host": "production.example.com"
            }
        }' && log_success "SSH keys added" || log_warn "SSH keys might already exist"
}

# Main execution
main() {
    log_info "Starting Vault initialization for VERMEG SIRH..."
    log_info "Vault address: $VAULT_ADDR"
    
    check_vault
    init_vault
    unseal_vault
    setup_secret_engines
    setup_auth_policies
    create_service_accounts
    seed_example_secrets
    
    log_success "Vault setup completed successfully!"
    log_info "Next steps:"
    log_info "1. Update the default secrets with your actual values"
    log_info "2. Store the unseal keys and root token securely"
    log_info "3. Enable AppRole and generate role-id and secret-id for applications"
    log_info "4. Update CI/CD workflow to use Vault authentication"
}

main
