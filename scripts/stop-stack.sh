#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-}"
PF_PID_DIR="$ROOT_DIR/.k8s-port-forward-pids"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/stop-stack.sh docker
  ./scripts/stop-stack.sh k8s
EOF
}

stop_k8s_port_forwards() {
  if [ -d "$PF_PID_DIR" ]; then
    for pid_file in "$PF_PID_DIR"/*.pid; do
      [ -e "$pid_file" ] || continue
      pid="$(cat "$pid_file")"
      kill "$pid" >/dev/null 2>&1 || true
      rm -f "$pid_file"
    done
  fi
}

case "$MODE" in
  docker)
    cd "$ROOT_DIR"
    docker compose -f backend/docker-compose.yml stop
    ;;
  k8s)
    stop_k8s_port_forwards
    kubectl scale statefulset/postgres --replicas=0 -n vermeg >/dev/null 2>&1 || true
    kubectl scale deployment/keycloak --replicas=0 -n vermeg >/dev/null 2>&1 || true
    kubectl scale deployment/employee-service --replicas=0 -n vermeg >/dev/null 2>&1 || true
    kubectl scale deployment/recruitment-service --replicas=0 -n vermeg >/dev/null 2>&1 || true
    kubectl scale deployment/approval-service --replicas=0 -n vermeg >/dev/null 2>&1 || true
    kubectl scale deployment/api-gateway --replicas=0 -n vermeg >/dev/null 2>&1 || true
    kubectl scale deployment/frontend --replicas=0 -n vermeg >/dev/null 2>&1 || true
    ;;
  *)
    usage
    exit 1
    ;;
esac
