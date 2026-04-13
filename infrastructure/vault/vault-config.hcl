# HashiCorp Vault Configuration for VERMEG SIRH
# Secure secrets management and credential rotation

ui = true
api_addr = "http://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"

# Storage Backend - file storage for development/testing
storage "file" {
  path = "/vault/file"
}

# Storage Backend - PostgreSQL for production
# Uncomment and configure for production use
# storage "postgresql" {
#   connection_url = "postgresql://{{username}}:{{password}}@db-host:5432/vault"
#   table = "vault_kv_store"
# }

# In-Memory storage for sealed keys
#seal "awskms" {
#  region     = "us-east-1"
#  kms_key_id = "12345678-1234-1234-1234-123456789012"
#}

# Listener configuration
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = "true"  # IMPORTANT: Enable TLS in production!
  # tls_cert_file = "/vault/tls/tls.crt"
  # tls_key_file  = "/vault/tls/tls.key"
}

listener "unix" {
  address = "/vault/socket"
}

# Telemetry
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = false
}

# Logging
log_level = "info"
log_format = "json"
