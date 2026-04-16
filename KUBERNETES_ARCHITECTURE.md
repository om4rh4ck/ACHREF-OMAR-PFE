# 🏗️ ARCHITECTURE KUBERNETES - VERMEG SIRH

## Vue d'Ensemble de l'Architecture

```
╔════════════════════════════════════════════════════════════════════════════╗
║                    KUBERNETES CLUSTER (Minikube)                           ║
║                                                                            ║
║  ┌──────────────────────── NAMESPACE: vermeg ──────────────────────────┐  ║
║  │                                                                     │  ║
║  │  ┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │  ║
║  │  │  API GATEWAY    │  │ EMPLOYEE SERVICE │  │ RECRUITMENT SRVC │  │  ║
║  │  │  (2 replicas)   │  │  (2 replicas)    │  │  (2 replicas)    │  │  ║
║  │  │                 │  │                  │  │                  │  │  ║
║  │  │ Pod 1  | Pod 2  │  │ Pod 1  | Pod 2   │  │ Pod 1  | Pod 2   │  │  ║
║  │  │ :8080  | :8080  │  │ :8080  | :8080   │  │ :8080  | :8080   │  │  ║
║  │  └─────────────────┘  └──────────────────┘  └──────────────────┘  │  ║
║  │         ▲                    ▲                      ▲               │  ║
║  │         │                    │                      │               │  ║
║  │         └────────────────────┴──────────────────────┘               │  ║
║  │                              │                                      │  ║
║  │                    ┌─────────▼─────────┐                           │  ║
║  │                    │   KUBE-PROXY      │                           │  ║
║  │                    │   (Load Balancer) │                           │  ║
║  │                    └─────────┬─────────┘                           │  ║
║  │                              │                                      │  ║
║  │  ┌───────────────────────────┼───────────────────────────────┐    │  ║
║  │  │                           │                               │    │  ║
║  │  ▼                           ▼                               ▼    │  ║
║  │  Service: api-gateway       Service: employee-service       Service  │  ║
║  │  NodePort: 30380            ClusterIP: 8080               :ClusterIP │  ║
║  │                                                           :8080    │  ║
║  │  ┌──────────────────────────────────────────────────────────────┐ │  ║
║  │  │           SECURITY DASHBOARD (Port 8099)                   │ │  ║
║  │  │           Pod: security-dashboard-xxxxx                   │ │  ║
║  │  │           NodePort: 30099                                 │ │  ║
║  │  └──────────────────────────────────────────────────────────────┘ │  ║
║  │                                                                     │  ║
║  └─────────────────────────────────────────────────────────────────────┘  ║
║                                                                            ║
║  ┌────────────────── NAMESPACE: vermeg-db ─────────────────────────────┐  ║
║  │                                                                     │  ║
║  │        ┌─────────────────────────────────────────┐                │  ║
║  │        │       POSTGRESQL (StatefulSet)          │                │  ║
║  │        │                                         │                │  ║
║  │        │  Pod: postgres-0                        │                │  ║
║  │        │  Container: PostgreSQL 13               │                │  ║
║  │        │  Port: 5432                             │                │  ║
║  │        └─────────────────────────────────────────┘                │  ║
║  │                       │                                            │  ║
║  │                       ▼                                            │  ║
║  │        ┌─────────────────────────────────────────┐                │  ║
║  │        │  PersistentVolumeClaim (10Gi)           │                │  ║
║  │        │  Stockage persistant: /var/lib/pg/data  │                │  ║
║  │        └─────────────────────────────────────────┘                │  ║
║  │                                                                     │  ║
║  │        Service: postgres-service                                   │  ║
║  │        ClusterIP: None (Headless)                                 │  ║
║  │        Port: 5432                                                 │  ║
║  │                                                                     │  ║
║  └─────────────────────────────────────────────────────────────────────┘  ║
║                                                                            ║
║  ┌───────────────── GLOBAL CONFIG ───────────────────────────────────┐  ║
║  │  ConfigMap: vermeg-config (Variables d'env)                       │  ║
║  │  ConfigMap: vermeg-db-config (Config DB)                          │  ║
║  └─────────────────────────────────────────────────────────────────────┘  ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────┐
│                          ACCÈS EXTERNES                                  │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  http://<minikube-ip>:30380     ──────►  API Gateway  (8080)           │
│  http://<minikube-ip>:30099     ──────►  Security Dashboard (8099)     │
│                                                                          │
│  <minikube-ip>:30432 (optionnel) ──────► PostgreSQL (5432)             │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 COMMUNICATION INTERNE (Service Discovery)

### Noms DNS Internes

Chaque service a un **DNS automatique**:
```
<service-name>.<namespace>.svc.cluster.local
```

### Exemples dans VERMEG SIRH

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    RÉSEAU INTERNE DU CLUSTER                            │
│                                                                          │
│  ┌─────────────────────┐                                               │
│  │  API GATEWAY        │                                               │
│  │  └─ Veut appeler:   │                                               │
│  │     - Employee API  │                                               │
│  │     - Recruitment   │                                               │
│  │     - Security DB   │                                               │
│  └──────────┬──────────┘                                               │
│             │                                                           │
│             ├──► http://employee-service.vermeg.svc.cluster.local:8080 │
│             │    ✓ Résout à n'importe quel pod employee-service      │
│             │    ✓ Load balancer automatique                          │
│             │                                                           │
│             ├──► http://recruitment-service.vermeg.svc.cluster.local:8080
│             │    ✓ Résout à n'importe quel pod recruitment-service   │
│             │                                                           │
│             └──► postgresql://postgres-service.vermeg-db.svc.cluster.local:5432
│                  ✓ Résout au pod PostgreSQL                           │
│                  ✓ Même si le pod redémarre, le DNS reste le même    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 💾 STOCKAGE & PERSISTANCE

### Cycle de Vie

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DONNÉES PERSISTANTES                                 │
│                                                                         │
│   PersistentVolume (PV)                  PersistentVolumeClaim (PVC)   │
│   ┌──────────────────────┐               ┌──────────────────────────┐  │
│   │ Stockage physique   │  ◄──────────►  │ Demande de stockage     │  │
│   │ (10Gi sur l'hôte)   │               │ (PostgreSQL)             │  │
│   │                      │               │                          │  │
│   │ /mnt/data/postgres   │               │ postgres-pvc             │  │
│   │                      │               │ Namespace: vermeg-db     │  │
│   └──────────────────────┘               └──────────────────────────┘  │
│           ▲                                         │                  │
│           │                                        ▼                  │
│           │                            ┌──────────────────────────┐  │
│           │                            │ StatefulSet: postgres    │  │
│           │                            │ Pod: postgres-0          │  │
│           │                            │ Mount: /var/lib/pg/data  │  │
│           │                            └──────────────────────────┘  │
│           └────────────────────────────────────────────────────────   │
│                                                                         │
│   ✓ Données survivent si le pod meurt                                 │
│   ✓ Données survivent si le cluster redémarre                         │
│   ✓ Seul PostgreSQL peut accéder (accessMode: ReadWriteOnce)          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Volumes Temporaires (emptyDir)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                   DONNÉES TEMPORAIRES                                   │
│                                                                         │
│   emptyDir Volume              CreationTimestamp: Pod start            │
│   ┌──────────────────────┐     DeletionTimestamp: Pod deletion         │
│   │ Stockage temporaire │                                              │
│   │ (RAM ou Disk)       │     ┌──────────────────────────────┐         │
│   │                      │     │ Pod: api-gateway-xxxxx      │         │
│   │ /app/logs/           │──► │ Volume: logs (emptyDir)     │         │
│   │ /app/cache/          │     │ Mount: /tmp/logs            │         │
│   │                      │     └──────────────────────────────┘         │
│   └──────────────────────┘                                              │
│           ▲                                                              │
│      ✓ Utile pour cache de pod pod-local                              │
│      ✓ Supprimé quand le pod meurt                                    │
│      ✓ Pas de persistance entre redémarrages                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🏥 HEALTH CHECKS & AUTO-RESTART

### Cycle de VieVigilance d'un Pod

```
            POD START
                 │
                 ▼
        ┌────────────────┐
        │  Init Container│  ◄─── Chec les dépendances (DB, Services)
        └────────┬───────┘
                 │       Erreur? ──► Pod reste en "Init" ──► Restart
                 ▼
        ┌────────────────┐
        │ Main Container │  
        │    Démarrage   │
        └────────┬───────┘
                 │
          Attendre 30s (initialDelaySeconds)
                 │
                 ▼
        ┌────────────────────────────────────────┐
        │  LIVENESS PROBE: /api/health           │
        │  Vérifie chaque 10s (periodSeconds)    │
        │  Timeout après 5s                      │
        │                                        │
        │  ✓ Réponse 200-399? ──► OK, continue  │
        │  ✗ Erreur ou timeout? ──► Compte++    │
        │                                        │
        │  Après 3 échecs (failureThreshold)    │
        │  ──► Pod meurt et redémarre!          │
        └────────────┬───────────────────────────┘
                     │
             Attendre 10s
                     │
                     ▼
        ┌────────────────────────────────────────┐
        │  READINESS PROBE: /api/ready           │
        │  Vérifie chaque 5s (periodSeconds)     │
        │                                        │
        │  ✓ Réponse 200-399? ────┐            │
        │  ✗ Erreur ou timeout?   │            │
        │  (failureThreshold: 2)  │            │
        │                         │            │
        │  Service peut router    │            │
        │  le trafic? ◄───────────┘            │
        │  NON = Pod retiré du load balancer   │
        └────────────────────────────────────────┘
                     │
            [Application en cours]
                     │
             ▼ (Erreur!)
        ┌────────────────┐
        │ Pod CRASH      │
        │                │
        │ Automatique:   │
        │ └─ Redémarrage │
        │    (RestartPolicy)
        └────────────────┘
```

---

## 🔄 DÉPLOIEMENT & UPDATES (Rolling Update)

### Stratégie par Défaut

```
Current State: 2 replicas en production
Desire: Nouvelle version avec 2 replicas

ROLLING UPDATE:
═════════════════════════════════════════════════════════════

INITIAL (v1):
  Pod-1-v1 (Running)
  Pod-2-v1 (Running)

ÉTAPE 1:
  Pod-1-v1 (Terminating) ──────────► Pod-3-v2 (Starting)
  Pod-2-v1 (Running)                 Pod-2-v2 (Starting)
  
    Check readinessProbe sur Pod-3-v2
    OK? ──► Passer à l'étape suivante
    
ÉTAPE 2:
  Pod-1-v2 (Running)
  Pod-2-v1 (Terminating) ────────► Pod-4-v2 (Starting)
  
    Check readinessProbe sur Pod-4-v2
    OK? ──► Transition complète!

FINAL (v2):
  Pod-1-v2 (Running)
  Pod-2-v2 (Running)
  
  ✓ Zéro downtime!
  ✓ Traffic toujours disponible
  ✓ Rollback facile si erreur
```

---

## 🎯 NAMESPACES (Isolation)

```
┌──────────────────────────────────────────────────────────────────────┐
│                    CLUSTER KUBERNETES                               │
│                                                                      │
│  ┌──────────────────────────┐     ┌─────────────────────────────┐  │
│  │  Namespace: vermeg       │     │  Namespace: vermeg-db       │  │
│  │  (Microservices)         │     │  (Bases de données)         │  │
│  │                          │     │                             │  │
│  │  ✓ employee-service     │     │  ✓ postgres                │  │
│  │  ✓ recruitment-service  │     │  ✓ pvc (10Gi)              │  │
│  │  ✓ api-gateway          │     │  ✓ postgres-service        │  │
│  │  ✓ security-dashboard   │     │                             │  │
│  │  ✓ ConfigMap: config    │     │  ✓ ConfigMap: db-config    │  │
│  │  ✓ Secrets (optionnel)  │     │  ✓ Secrets (optionnel)     │  │
│  │                          │     │                             │  │
│  │  RBAC:                   │     │  RBAC:                      │  │
│  │  ├─ Can access: vermeg  │     │  ├─ Isolated               │  │
│  │  ├─ Cannot access:      │     │  └─ No vermeg traffic      │  │
│  │  │  vermeg-db           │     │                             │  │
│  │  └─ Cannot see pods     │     │                             │  │
│  │     d'autres namespaces │     │                             │  │
│  └──────────────────────────┘     └─────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────┐     ┌─────────────────────────────┐  │
│  │  Namespace: kube-system  │     │  Namespace: default         │  │
│  │  (Système Kubernetes)    │     │  (Non utilisé)              │  │
│  │                          │     │                             │  │
│  │  ✓ kube-proxy           │     │  ✓ [Vide normalement]      │  │
│  │  ✓ coredns              │     │                             │  │
│  │  ✓ etcd                 │     │                             │  │
│  └──────────────────────────┘     └─────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 📊 RESSOURCES & LIMITES

### Requests vs Limits

```
┌─────────────────────────────────────────────────────────────┐
│  Nœud Kubernetes (CPU: 4, RAM: 8Gi disponible)             │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Pod: api-gateway-111                                │  │
│  │                                                      │  │
│  │ Requests: CPU=100m, RAM=256Mi                       │  │
│  │   ↓ Minimaliste pour démarrer                      │  │
│  │ Limits: CPU=500m, RAM=512Mi                        │  │
│  │   ↓ Maximum autorisé (sinon tué!)                  │  │
│  │                                                      │  │
│  │ ┌────────────────────────────────────┐             │  │
│  │ │ RAM actuelle: 300Mi (entre req/limit) ✓         │  │
│  │ └────────────────────────────────────┘             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Pod: employee-service-222                          │  │
│  │                                                      │  │
│  │ Requests: CPU=100m, RAM=256Mi                      │  │
│  │ Limits: CPU=500m, RAM=512Mi                        │  │
│  │                                                      │  │
│  │ ┌────────────────────────────────────┐             │  │
│  │ │ RAM actuelle: 480Mi (proche limit!) ⚠️           │  │
│  │ │ Utilisation CPU: 400m (< limit) ✓               │  │
│  │ └────────────────────────────────────┘             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Pod: postgres-0                                    │  │
│  │                                                      │  │
│  │ Requests: CPU=500m, RAM=1Gi                        │  │
│  │ Limits: CPU=1Gi, RAM=2Gi                           │  │
│  │                                                      │  │
│  │ ┌────────────────────────────────────┐             │  │
│  │ │ RAM actuelle: 1.5Gi (< limit) ✓               │  │
│  │ │ Utilisation CPU: 800m (< limit) ✓               │  │
│  │ └────────────────────────────────────┘             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  NŒUD TOTAL UTILISÉ:                                      │
│    CPU: 600m / 4000m = 15% ✓ (OK)                        │
│    RAM: 2.28Gi / 8Gi = 28.5% ✓ (OK)                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 POINT D'ACCÈS RÉSEAU

### De l'Extérieur (Votre Machine)

```
┌───────────────────────────────────────────────────────────────┐
│              VOTRE ORDINATEUR (Windows)                       │
│              Browser: http://192.168.49.2:30380             │
│                                                               │
│                          │                                    │
│              (DNS résout à Minikube)                         │
│                          │                                    │
│                          ▼                                    │
│              192.168.49.2:30380 (NodePort)                  │
│                    │                                         │
│                    ▼                                         │
│  ┌──────────────────────────────────────┐                  │
│  │    MINIKUBE (VM Linux sur WSL)       │                  │
│  │    IP: 192.168.49.2                  │                  │
│  │                                       │                  │
│  │  Nœud Kubernetes ──► Node Port 30380 │                  │
│  │  ├─ Reçoit port 30380                │                  │
│  │  └─ Routage vers...                  │                  │
│  │                                       │                  │
│  │  Service: api-gateway                │                  │
│  │  ClusterIP: 10.0.0.5 (port 8080)    │                  │
│  │     │                                 │                  │
│  │     └──► Pod-1 (port 8080)           │                  │
│  │     └──► Pod-2 (port 8080)           │                  │
│  │         [Load balancer auto]          │                  │
│  │                                       │                  │
│  └──────────────────────────────────────┘                  │
│                                                               │
│  ✓ Votre requête arrive à un pod                            │
│  ✓ Si ce pod meurt, une autre répond                       │
│  ✓ C'est automatique!                                       │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

---

## 🔄 RÉSUMÉ CYCLE DE VIE COMPLET

```
User → Browser → Minikube:30380
  │
  ▼
Service: api-gateway (ClusterIP=10.0.0.5:8080)
  ├─► Load Balancer
  │   ├─ Pod-1 (10.1.0.1:8080)
  │   ├─ Pod-2 (10.1.0.2:8080)
  │   └─ Sélectionne aléatoire
  │
  ▼
Pod: api-gateway-111
  ├─ Container: api-gateway
  ├─ Port: 8080
  ├─ Env: ConfigMap vermeg-config
  │
  └─ Health Check
     ├─ Liveness: /api/health (10s)
     ├─ Readiness: /api/ready (5s)
     │
     └─ Si erreur ──► Pod redémarre
        (RestartPolicy=Always)

Si Pod besoin appeler BD:
  ├─ Appel à: postgres-service.vermeg-db.svc.cluster.local:5432
  ├─ DNS interne résout
  ├─ Kube-proxy routage
  └─ Pod: postgres-0
     ├─ Container: PostgreSQL
     ├─ Port: 5432
     └─ Volume: PVC (stockage 10Gi)
```

---

## ✅ CHECKLIST DE COMPRÉHENSION

- [ ] Je comprends Namespace = Isolationlogique
- [ ] Je comprends Service = DNS + Load Balancer
- [ ] Je comprends Pod = Regroupe 1+ conteneurs
- [ ] Je comprends Deployment = Gère réplicas
- [ ] Je comprends Volume = Stockage
- [ ] Je comprends Health Probes = Auto-restart
- [ ] Je comprends NodePort = Accès depuis dehors
- [ ] Je comprends ConfigMap = Variables
- [ ] Je comprends StatefulSet = Pour bases de données

---

**Continuez vers KUBERNETES_QUICK_START.md pour commencer! 🚀**
