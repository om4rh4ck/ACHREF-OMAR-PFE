# Kubernetes Base Setup

Cette version fournit une orchestration Kubernetes simple alignee sur la stack actuelle du projet.

## Ce qui est inclus

- `postgres`
- `keycloak`
- `employee-service`
- `recruitment-service`
- `approval-service`
- `api-gateway`
- `frontend`

## Avant de deployer

1. Verifier que les images `2025omar/vermeg-*` existent sur Docker Hub avec le tag `latest`
2. Si vous utilisez Minikube, activer un cluster local

## Deploiement

```bash
kubectl apply -k kubernetes
kubectl get all -n vermeg
```

## CI/CD Kubernetes

Le workflow GitHub Actions `cd.yml` supporte maintenant un deploiement Kubernetes manuel via `workflow_dispatch`.

Secrets GitHub requis:

- `KUBE_CONFIG_DATA`: contenu du kubeconfig encode en base64
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

Exemple pour generer `KUBE_CONFIG_DATA`:

```bash
base64 -w 0 ~/.kube/config
```

Dans GitHub Actions:

1. Ouvrir `Actions`
2. Choisir le workflow `cd`
3. Cliquer sur `Run workflow`
4. Choisir `deploy_target = kubernetes`

## Acces local avec Minikube

```bash
minikube service frontend -n vermeg
minikube service keycloak -n vermeg
minikube service api-gateway -n vermeg
```

## Notes importantes

- Les probes utilisent `tcpSocket` pour les microservices Spring qui n'exposent pas encore clairement un endpoint Actuator.
- Le gateway utilise `/actuator/health` car Actuator est bien present dans le projet.
- Le realm Keycloak est importe automatiquement via `kubernetes/keycloak-realm.json`.
- Les dependances entre microservices ne sont pas gerees par des `initContainers` afin d'eviter les blocages circulaires au demarrage. Chaque service demarre des que PostgreSQL et Keycloak sont disponibles.
- Les secrets sont volontairement simples pour t'aider a demarrer. Avant une vraie prod, il faudra brancher Vault ou `ExternalSecret`.
