#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-}"
BUILD_FLAG="${2:-}"
PF_PID_DIR="$ROOT_DIR/.k8s-port-forward-pids"
PF_LOG_DIR="$ROOT_DIR/.k8s-port-forward-logs"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/run-stack.sh docker [--build]
  ./scripts/run-stack.sh k8s

Modes:
  docker   Run the project with Docker Compose on localhost ports
  k8s      Run the project on Kubernetes and expose the same localhost ports via port-forward
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

ensure_k8s_cluster() {
  if kubectl cluster-info >/dev/null 2>&1; then
    return 0
  fi

  echo "Kubernetes cluster is not reachable."
  if command -v minikube >/dev/null 2>&1; then
    echo "Trying to start Minikube..."
    minikube start --driver=docker
    if kubectl cluster-info >/dev/null 2>&1; then
      return 0
    fi
  fi

  cat >&2 <<'EOF'
Unable to reach a Kubernetes cluster.
Please verify your local cluster, for example:
  minikube status
  minikube start --driver=docker
  kubectl cluster-info
EOF
  exit 1
}

ensure_port_free() {
  local port="$1"
  if command -v ss >/dev/null 2>&1 && ss -ltn "( sport = :$port )" | tail -n +2 | grep -q .; then
    echo "Port $port is already in use. Free it before continuing." >&2
    exit 1
  fi
}

wait_for_statefulset_ready() {
  local name="$1"
  kubectl rollout status "statefulset/$name" -n vermeg --timeout=180s
}

wait_for_deployment_available() {
  local name="$1"
  kubectl wait --for=condition=Available "deployment/$name" -n vermeg --timeout=240s
}

stop_k8s_port_forwards() {
  if [ -d "$PF_PID_DIR" ]; then
    for pid_file in "$PF_PID_DIR"/*.pid; do
      [ -e "$pid_file" ] || continue
      pid="$(cat "$pid_file")"
      if kill -0 "$pid" >/dev/null 2>&1; then
        kill "$pid" >/dev/null 2>&1 || true
      fi
      rm -f "$pid_file"
    done
  fi
}

start_port_forward() {
  local service="$1"
  local local_port="$2"
  local remote_port="$3"
  local log_file="$PF_LOG_DIR/$service.log"
  local pid_file="$PF_PID_DIR/$service.pid"

  ensure_port_free "$local_port"
  nohup kubectl port-forward -n vermeg "svc/$service" "$local_port:$remote_port" >"$log_file" 2>&1 &
  local pf_pid=$!
  echo "$pf_pid" >"$pid_file"

  for _ in $(seq 1 20); do
    if ! kill -0 "$pf_pid" >/dev/null 2>&1; then
      echo "Port-forward for $service failed. See $log_file" >&2
      cat "$log_file" >&2 || true
      exit 1
    fi
    if command -v ss >/dev/null 2>&1 && ss -ltn "( sport = :$local_port )" | tail -n +2 | grep -q .; then
      return 0
    fi
    sleep 1
  done

  echo "Port-forward for $service did not become ready in time. See $log_file" >&2
  exit 1
}

run_docker() {
  require_cmd docker
  cd "$ROOT_DIR"
  if [ "$BUILD_FLAG" = "--build" ]; then
    docker compose -f backend/docker-compose.yml up -d --build
  else
    docker compose -f backend/docker-compose.yml up -d
  fi

  cat <<'EOF'
Project is running with Docker Compose.

URLs:
  Frontend: http://localhost:5173
  Keycloak: http://localhost:8080
  API Gateway: http://localhost:8081
  PostgreSQL: localhost:5432
EOF
}

run_k8s() {
  require_cmd kubectl
  ensure_k8s_cluster
  mkdir -p "$PF_PID_DIR" "$PF_LOG_DIR"

  cd "$ROOT_DIR"
  kubectl apply -k kubernetes

  wait_for_statefulset_ready postgres
  wait_for_deployment_available keycloak
  wait_for_deployment_available employee-service
  wait_for_deployment_available recruitment-service
  wait_for_deployment_available approval-service
  wait_for_deployment_available api-gateway
  wait_for_deployment_available frontend

  stop_k8s_port_forwards
  start_port_forward "frontend" 5173 80
  start_port_forward "keycloak" 8080 8080
  start_port_forward "api-gateway" 8081 8081
  start_port_forward "postgres" 5432 5432

  cat <<EOF
Project is running on Kubernetes with localhost port-forwards.

URLs:
  Frontend: http://localhost:5173
  Keycloak: http://localhost:8080
  API Gateway: http://localhost:8081
  PostgreSQL: localhost:5432

Port-forward logs:
  $PF_LOG_DIR/frontend.log
  $PF_LOG_DIR/keycloak.log
  $PF_LOG_DIR/api-gateway.log
  $PF_LOG_DIR/postgres.log
EOF
}

case "$MODE" in
  docker)
    run_docker
    ;;
  k8s)
    run_k8s
    ;;
  *)
    usage
    exit 1
    ;;
esac
