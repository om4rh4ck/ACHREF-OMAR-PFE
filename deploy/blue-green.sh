#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-latest}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTIVE_FILE="$ROOT_DIR/.active"
ROUTER_ENV="$ROOT_DIR/router.env"

if [ -f "$ACTIVE_FILE" ]; then
  ACTIVE="$(cat "$ACTIVE_FILE")"
else
  ACTIVE="blue"
fi

if [ "$ACTIVE" = "blue" ]; then
  TARGET="green"
else
  TARGET="blue"
fi

echo "Active stack: $ACTIVE"
echo "Target stack: $TARGET"

docker network create vermeg-net >/dev/null 2>&1 || true

docker compose -f "$ROOT_DIR/docker-compose.base.yml" up -d

if [ "$TARGET" = "blue" ]; then
  ENV_FILE="$ROOT_DIR/blue.env"
else
  ENV_FILE="$ROOT_DIR/green.env"
fi

DOCKERHUB_USER="$(grep -E '^DOCKERHUB_USER=' "$ENV_FILE" | cut -d= -f2)"
STACK_NAME="$(grep -E '^STACK=' "$ENV_FILE" | cut -d= -f2)"
FRONTEND_PORT="$(grep -E '^FRONTEND_PORT=' "$ENV_FILE" | cut -d= -f2)"
API_PORT="$(grep -E '^API_PORT=' "$ENV_FILE" | cut -d= -f2)"
ROUTER_PORT="$(grep -E '^ROUTER_PORT=' "$ENV_FILE" | cut -d= -f2)"

export TAG
export DOCKERHUB_USER
export STACK_NAME
export ROUTER_PORT

docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/docker-compose.app.yml" up -d

cat > "$ROUTER_ENV" <<EOF
ACTIVE_FRONTEND_HOST=frontend-$TARGET
ACTIVE_FRONTEND_PORT=${FRONTEND_PORT:-80}
ACTIVE_API_HOST=api-gateway-$TARGET
ACTIVE_API_PORT=${API_PORT:-8081}
ROUTER_PORT=${ROUTER_PORT:-80}
EOF

docker compose -f "$ROOT_DIR/docker-compose.router.yml" up -d

echo "$TARGET" > "$ACTIVE_FILE"

echo "Cleaning old stack..."
if [ "$ACTIVE" = "blue" ]; then
  docker compose --env-file "$ROOT_DIR/blue.env" -f "$ROOT_DIR/docker-compose.app.yml" down
else
  docker compose --env-file "$ROOT_DIR/green.env" -f "$ROOT_DIR/docker-compose.app.yml" down
fi

echo "Blue/Green switch complete. Active: $TARGET"
