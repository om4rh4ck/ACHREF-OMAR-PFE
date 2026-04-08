#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-latest}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${DEPLOY_ENV_FILE:-$ROOT_DIR/rolling.env}"
ROUTER_ENV="$ROOT_DIR/router.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing env file: $ENV_FILE"
  exit 1
fi

docker network create vermeg-net >/dev/null 2>&1 || true
docker rm -f vermeg-postgres vermeg-keycloak >/dev/null 2>&1 || true
docker compose -f "$ROOT_DIR/docker-compose.base.yml" up -d

DOCKERHUB_USER="$(grep -E '^DOCKERHUB_USER=' "$ENV_FILE" | cut -d= -f2)"
STACK_NAME="$(grep -E '^STACK=' "$ENV_FILE" | cut -d= -f2)"
FRONTEND_PORT="$(grep -E '^FRONTEND_PORT=' "$ENV_FILE" | cut -d= -f2)"
API_PORT="$(grep -E '^API_PORT=' "$ENV_FILE" | cut -d= -f2)"
ROUTER_PORT="$(grep -E '^ROUTER_PORT=' "$ENV_FILE" | cut -d= -f2)"

export TAG
export DOCKERHUB_USER
export STACK_NAME
export ROUTER_PORT

docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/docker-compose.app.yml" pull
docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/docker-compose.app.yml" up -d

cat > "$ROUTER_ENV" <<EOF
ACTIVE_FRONTEND_HOST=frontend-$STACK_NAME
ACTIVE_FRONTEND_PORT=${FRONTEND_PORT:-80}
ACTIVE_API_HOST=api-gateway-$STACK_NAME
ACTIVE_API_PORT=${API_PORT:-8081}
ROUTER_PORT=${ROUTER_PORT:-80}
EOF

docker compose -f "$ROOT_DIR/docker-compose.router.yml" up -d

echo "Rolling deploy complete. Stack: $STACK_NAME"
