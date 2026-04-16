# 🐳 GUIDE ORCHESTRATION KUBERNETES - VERMEG SIRH
## Configuration Basique sur WSL (Windows Subsystem for Linux)

---

## 📋 TABLE DES MATIÈRES

1. **Préparation & Installation**
2. **Configuration Kubernetes Basique**
3. **Déploiement Multi-Conteneurs**
4. **Gestion des Réseaux (Services)**
5. **Volumes & Persistance**
6. **Health Checks & Auto-Restart**

---

## ⚡ ÉTAPE 1: PRÉPARATION & INSTALLATION

### 1.1 Vérifier WSL 2
```bash
# Terminal PowerShell (Admin)
wsl --list --verbose
# Vous devez voir WSL 2 activé pour votre distro

# Si besoin, définir WSL 2 par défaut:
wsl --set-default-version 2
```

### 1.2 Installer Docker sur WSL
```bash
# Dans WSL Terminal (Ubuntu)
sudo apt update
sudo apt upgrade -y

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# Vérifier l'installation
docker --version
docker run hello-world
```

### 1.3 Installer Kubernetes (minikube)
```bash
# ✅ INSTALLER MINIKUBE - Étape par étape avec vérification

# 1. Télécharger minikube
echo "📥 Téléchargement de minikube..."
curl -L -o minikube https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-x86_64

# 2. Vérifier que le téléchargement a réussi
if [ -f minikube ]; then
    echo "✅ minikube téléchargé avec succès"
else
    echo "❌ ERREUR: minikube n'a pas pu être téléchargé!"
    echo "Vérifiez votre connexion et réessayez"
    exit 1
fi

# 3. Installer minikube
echo "🔧 Installation de minikube dans /usr/local/bin/..."
sudo install -o root -g root -m 0755 minikube /usr/local/bin/
rm minikube

# 4. Vérifier l'installation
echo "🔍 Vérification..."
minikube version

# ===================================================

# ✅ INSTALLER KUBECTL - Outil pour contrôler Kubernetes

echo ""
echo "📥 Téléchargement de kubectl..."
# Récupérer la latest version stable
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
echo "Version: $KUBECTL_VERSION"

# Télécharger
curl -L -o kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

# 2. Vérifier que le téléchargement a réussi
if [ -f kubectl ]; then
    echo "✅ kubectl téléchargé avec succès"
else
    echo "❌ ERREUR: kubectl n'a pas pu être téléchargé!"
    exit 1
fi

# 3. Installer kubectl
echo "🔧 Installation de kubectl..."
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/
rm kubectl

# 4. Vérifier
echo "🔍 Vérification..."
kubectl version --client

echo ""
echo "✅ MINIKUBE ET KUBECTL INSTALLÉS AVEC SUCCÈS!"
```

**✅ À FAIRE SI ERREUR DE TÉLÉCHARGEMENT:**
```bash
# Si vous avez une erreur "cannot stat", c'est que le curl a échoué
# Essayez avec un timeout plus long:

# Pour minikube (avec retry):
MINIKUBE_URL="https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-x86_64"
curl -L --connect-timeout 30 --max-time 300 -o minikube "$MINIKUBE_URL"

# Vérifiez que le fichier existe:
ls -lh minikube
file minikube

# Puis installez:
sudo install -o root -g root -m 0755 minikube /usr/local/bin/
minikube version

# Pour kubectl (alternative: utiliser apt):
sudo apt update
sudo apt install -y kubectl
kubectl version --client
```

### 1.4 Démarrer le Cluster Kubernetes
```bash
# Démarrer minikube
minikube start --driver=docker

# Attendre ~30-60 secondes
# Résultat: ✅ Cluster démarré avec succès

# Vérifier le statut
minikube status
minikube dashboard  # Ouvre le dashboard Web (optionnel)
```

✅ **À cette étape, vous avez:**
- WSL 2 configuré
- Docker installé et fonctionnel
- Minikube et kubectl prêts
- Cluster Kubernetes en cours d'exécution

---

## 🏗️ ÉTAPE 2: CONFIGURATION KUBERNETES BASIQUE

### 2.1 Structure de Projet Kubernetes
Créer la structure dans votre projet:
```
kubernetes/
├── namespaces.yaml          # Namespaces (dev, prod, etc.)
├── config-maps.yaml         # Variables de configuration
├── secrets.yaml             # Données sensibles
├── employee-service/
│   ├── deployment.yaml      # Define pods
│   ├── service.yaml         # Expose le service
│   ├── pvc.yaml             # Volume persistant
│   └── configmap.yaml       # Config spécifique
├── recruitment-service/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── pvc.yaml
├── api-gateway/
│   ├── deployment.yaml
│   └── service.yaml
├── frontend/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── database/
│   ├── statefulset.yaml     # Base de données
│   ├── service.yaml
│   └── pvc.yaml
└── dashboard/
    ├── deployment.yaml      # Dashboard sécurité (Port 8099!)
    └── service.yaml
```

### 2.2 Créer le Namespace
Fichier: `kubernetes/namespaces.yaml`
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: vermeg
  labels:
    name: vermeg

---
apiVersion: v1
kind: Namespace
metadata:
  name: vermeg-db
  labels:
    name: vermeg-db
```

**À FAIRE:**
1. Créer le dossier `kubernetes/` à la racine du projet
2. Copier le contenu YAML ci-dessus dans `kubernetes/namespaces.yaml`
3. Exécuter:
```bash
kubectl apply -f kubernetes/namespaces.yaml

# Vérifier
kubectl get namespaces
# Vous devez voir: vermeg et vermeg-db
```

### 2.3 Créer ConfigMap Global
Fichier: `kubernetes/config-maps.yaml`
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vermeg-config
  namespace: vermeg
data:
  # Environment variables
  ENVIRONMENT: "production"
  LOG_LEVEL: "info"
  DATABASE_HOST: "postgres-service.vermeg-db.svc.cluster.local"
  DATABASE_PORT: "5432"
  DATABASE_NAME: "vermeg_db"
  API_GATEWAY_PORT: "8080"
  FRONTEND_PORT: "5173"
  DASHBOARD_PORT: "8099"
  
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: vermeg-db-config
  namespace: vermeg-db
data:
  POSTGRES_DB: "vermeg_db"
  POSTGRES_USER: "vermeg_admin"
```

**À FAIRE:**
1. Créer `kubernetes/config-maps.yaml`
2. Exécuter:
```bash
kubectl apply -f kubernetes/config-maps.yaml

# Vérifier
kubectl get configmaps -n vermeg
kubectl get configmaps -n vermeg-db
```

---

## 🚀 ÉTAPE 3: DÉPLOIEMENT MULTI-CONTENEURS

### 3.1 Deployer Employee Service
Fichier: `kubernetes/employee-service/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: employee-service
  namespace: vermeg
  labels:
    app: employee-service
    version: v1
spec:
  replicas: 2  # 2 pods pour la haute disponibilité
  selector:
    matchLabels:
      app: employee-service
  
  template:
    metadata:
      labels:
        app: employee-service
        version: v1
    
    spec:
      # ⏱️ Attendre que le conteneur soit prêt
      initContainers:
      - name: wait-for-db
        image: busybox:1.35
        command: ['sh', '-c', 'until nc -z postgres-service.vermeg-db.svc.cluster.local 5432; do echo "Attendre DB..."; sleep 2; done']
      
      containers:
      - name: employee-service
        image: employee-service:latest  # Build locale ou registry
        imagePullPolicy: IfNotPresent    # Utiliser image locale d'abord
        
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        
        # Variables d'environnement
        env:
        - name: JAVA_OPTS
          value: "-Xmx512m -Xms256m"
        - name: DATABASE_URL
          value: "jdbc:postgresql://postgres-service.vermeg-db/vermeg_db"
        
        # De ConfigMap
        envFrom:
        - configMapRef:
            name: vermeg-config
        
        # Health Check (très important!)
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 30    # Attendre 30s avant de vérifier
          periodSeconds: 10          # Vérifier toutes les 10s
          timeoutSeconds: 5
          failureThreshold: 3        # Redémarrer après 3 échecs
        
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        
        # Ressources (limites)
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # Volume de log
        volumeMounts:
        - name: logs
          mountPath: /app/logs
      
      # Volume (voir section 5)
      volumes:
      - name: logs
        emptyDir: {}  # Stockage temporaire pod
```

**À FAIRE:**
1. Créer `kubernetes/employee-service/` dossier
2. Créer `kubernetes/employee-service/deployment.yaml` avec le contenu ci-dessus
3. Exécuter:
```bash
kubectl apply -f kubernetes/employee-service/deployment.yaml

# Vérifier
kubectl get deployments -n vermeg
kubectl get pods -n vermeg
kubectl logs -n vermeg deployment/employee-service --tail=50
```

### 3.2 Deployer API Gateway
Fichier: `kubernetes/api-gateway/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: vermeg
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
  
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api-gateway
        image: api-gateway:latest
        ports:
        - containerPort: 8080
        
        envFrom:
        - configMapRef:
            name: vermeg-config
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
        
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

**À FAIRE:**
1. Créer `kubernetes/api-gateway/deployment.yaml`
2. Exécuter:
```bash
kubectl apply -f kubernetes/api-gateway/deployment.yaml
kubectl get pods -n vermeg
```

### 3.3 Deployer Security Dashboard
Fichier: `kubernetes/dashboard/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: security-dashboard
  namespace: vermeg
  labels:
    app: security-dashboard
spec:
  replicas: 1
  selector:
    matchLabels:
      app: security-dashboard
  
  template:
    metadata:
      labels:
        app: security-dashboard
    spec:
      containers:
      - name: dashboard
        image: node:16-alpine
        
        ports:
        - containerPort: 8099
          name: dashboard
        
        # Copier code et démarrer
        command:
        - /bin/sh
        - -c
        - |
          cd /app
          npm install
          node security-dashboard-server.js
        
        volumeMounts:
        - name: dashboard-code
          mountPath: /app
        - name: reports-history
          mountPath: /app/reports-history
        
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "8099"
        
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8099
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /
            port: 8099
          initialDelaySeconds: 15
          periodSeconds: 5
      
      volumes:
      - name: dashboard-code
        emptyDir: {}  # À remplacer par ConfigMap pour le code
      - name: reports-history
        emptyDir: {}  # À remplacer par PVC pour la persistance
```

**À FAIRE:**
1. Créer `kubernetes/dashboard/deployment.yaml`
2. Exécuter:
```bash
kubectl apply -f kubernetes/dashboard/deployment.yaml
kubectl get pods -n vermeg -l app=security-dashboard
```

---

## 🌐 ÉTAPE 4: GESTION DES RÉSEAUX (Services)

### 4.1 Concept Services Kubernetes
Les Services exposent les pods sur le réseau interne du cluster.

**Types:**
- **ClusterIP** (par défaut) - Accès interne seulement
- **NodePort** - Expose port sur les nœuds (accès externe)
- **LoadBalancer** - Équilibreur de charge
- **ExternalName** - Service externe dans le cluster

### 4.2 Service pour Employee Service
Fichier: `kubernetes/employee-service/service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: employee-service
  namespace: vermeg
  labels:
    app: employee-service
spec:
  type: ClusterIP  # Accès interne uniquement
  
  selector:
    app: employee-service
  
  ports:
  - port: 8080        # Port sur le service
    targetPort: 8080  # Port du pod
    protocol: TCP
    name: http
```

**À FAIRE:**
1. Créer `kubernetes/employee-service/service.yaml`
2. Exécuter:
```bash
kubectl apply -f kubernetes/employee-service/service.yaml

# Vérifier
kubectl get services -n vermeg
kubectl get service employee-service -n vermeg -o yaml
```

### 4.3 Service pour API Gateway (Expose externalement)
Fichier: `kubernetes/api-gateway/service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: vermeg
spec:
  type: NodePort  # Accessible de l'extérieur
  
  selector:
    app: api-gateway
  
  ports:
  - port: 8080           # Port "virtuel"
    targetPort: 8080     # Port du pod
    nodePort: 30380      # Port sur le nœud (30000-32767)
    protocol: TCP
```

**À FAIRE:**
1. Créer `kubernetes/api-gateway/service.yaml`
2. Exécuter:
```bash
kubectl apply -f kubernetes/api-gateway/service.yaml

# Accéder au service
minikube service api-gateway -n vermeg
# Ou manuellement:
minikube ip  # e.g., 192.168.49.2
# Ouvrir: http://192.168.49.2:30380
```

### 4.4 Service pour Security Dashboard
Fichier: `kubernetes/dashboard/service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: security-dashboard
  namespace: vermeg
spec:
  type: NodePort
  
  selector:
    app: security-dashboard
  
  ports:
  - port: 8099
    targetPort: 8099
    nodePort: 30099
    name: dashboard
```

**À FAIRE:**
1. Créer `kubernetes/dashboard/service.yaml`
2. Exécuter:
```bash
kubectl apply -f kubernetes/dashboard/service.yaml

# Accéder au dashboard
minikube ip
# Ouvrir: http://<minikube-ip>:30099
```

### 4.5 Communication interne Entre Services
**IMPORTANT:** Kubernetes crée des noms DNS automatiquement:
```
<service-name>.<namespace>.svc.cluster.local
```

Exemples:
```
employee-service.vermeg.svc.cluster.local:8080
recruitment-service.vermeg.svc.cluster.local:8080
api-gateway.vermeg.svc.cluster.local:8080
```

**À FAIRE:**
1. Tester la connection:
```bash
# Accéder à un pod
kubectl exec -it deployment/api-gateway -n vermeg -- /bin/bash

# Depuis le pod, tester:
curl http://employee-service.vermeg.svc.cluster.local:8080/api/health
curl http://api-gateway.vermeg.svc.cluster.local:8080/api/health
```

---

## 💾 ÉTAPE 5: VOLUMES & PERSISTANCE

### 5.1 Types de Volumes

| Type | Durée de vie | Cas d'usage |
|------|-------------|-----------|
| **emptyDir** | Vie du Pod | Cache temporaire |
| **hostPath** | Durée du nœud | Dev/Test |
| **PersistentVolume (PV)** | Permanent | Bases de données |
| **ConfigMap** | Permanent | Fichiers config |
| **Secret** | Permanent | Données sensibles |

### 5.2 PersistentVolume pour Base de Données
Fichier: `kubernetes/database/pv.yaml`
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 10Gi  # 10 Gigabytes
  
  accessModes:
  - ReadWriteOnce  # Peut être monté par 1 pod
  
  hostPath:
    path: "/mnt/data/postgres"  # Sur le nœud
```

### 5.3 PersistentVolumeClaim (Demande de Volume)
Fichier: `kubernetes/database/pvc.yaml`
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: vermeg-db
spec:
  accessModes:
  - ReadWriteOnce
  
  resources:
    requests:
      storage: 10Gi
  
  # Optionnel: spécifier le storage class
  # storageClassName: fast-ssd
```

### 5.4 StatefulSet pour PostgreSQL
Fichier: `kubernetes/database/statefulset.yaml`
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: vermeg-db
spec:
  serviceName: postgres-service
  replicas: 1
  
  selector:
    matchLabels:
      app: postgres
  
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13-alpine
        
        ports:
        - containerPort: 5432
          name: postgres
        
        # Variables PostgreSQL
        env:
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: vermeg-db-config
              key: POSTGRES_DB
        
        - name: POSTGRES_USER
          valueFrom:
            configMapKeyRef:
              name: vermeg-db-config
              key: POSTGRES_USER
        
        - name: POSTGRES_PASSWORD
          value: "vermeg_secure_pwd_123"  # À mettre dans Secret!
        
        # Volume persistant
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        
        # Health checks
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U vermeg_admin
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U vermeg_admin
          initialDelaySeconds: 5
          periodSeconds: 5
  
  # Volume persistant
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

### 5.5 Service pour PostgreSQL
Fichier: `kubernetes/database/service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: vermeg-db
spec:
  clusterIP: None  # Headless service (utile pour StatefulSet)
  
  selector:
    app: postgres
  
  ports:
  - port: 5432
    targetPort: 5432
    name: postgres
```

### 5.6 Volume pour Dashboard History
Fichier: `kubernetes/dashboard/pvc.yaml`
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dashboard-reports-pvc
  namespace: vermeg
spec:
  accessModes:
  - ReadWriteOnce
  
  resources:
    requests:
      storage: 5Gi  # 5GB pour les rapports
```

**À FAIRE:**
1. Créer tous les fichiers de volumes
2. Exécuter:
```bash
kubectl apply -f kubernetes/database/pv.yaml
kubectl apply -f kubernetes/database/pvc.yaml
kubectl apply -f kubernetes/database/service.yaml
kubectl apply -f kubernetes/database/statefulset.yaml

# Vérifier
kubectl get pv
kubectl get pvc -n vermeg-db
kubectl get statefulset -n vermeg-db
kubectl get pods -n vermeg-db
```

---

## 🏥 ÉTAPE 6: HEALTH CHECKS & AUTO-RESTART

### 6.1 Types de Probes

#### **Liveness Probe** (Est-ce que le service fonctionne?)
Redémarre le pod si la probe échoue.

```yaml
livenessProbe:
  httpGet:           # Type: HTTP GET request
    path: /health
    port: 8080
  initialDelaySeconds: 30   # Attendre 30s avant de commencer
  periodSeconds: 10         # Vérifier toutes les 10s
  timeoutSeconds: 5         # Timeout après 5s
  failureThreshold: 3       # Redémarrer après 3 échecs consécutifs
```

#### **Readiness Probe** (Est-ce que le service est prêt à recevoir du trafic?)
Retire le pod du service si la probe échoue (sans le redémarrer).

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 2       # Retirer du service après 2 échecs
```

### 6.2 Types de Probes Disponibles

**1️⃣ HTTP GET**
```yaml
httpGet:
  path: /api/health
  port: 8080
  scheme: HTTP  # ou HTTPS
```

**2️⃣ TCP Socket** (vérifier si port écoute)
```yaml
tcpSocket:
  port: 5432
```

**3️⃣ Exec Command** (exécuter une commande)
```yaml
exec:
  command:
  - /bin/sh
  - -c
  - pg_isready -U users
```

### 6.3 Déploiement avec Health Checks Complets
Fichier: `kubernetes/employee-service/deployment-with-health-checks.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: employee-service-healthy
  namespace: vermeg
spec:
  replicas: 3
  
  selector:
    matchLabels:
      app: employee-service
  
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Créer 1 pod supplémentaire pendant mise à jour
      maxUnavailable: 0  # Garder tous les pods disponibles
  
  template:
    metadata:
      labels:
        app: employee-service
    spec:
      # IMPORTANT: Attendre que les dépendances soient prêtes
      initContainers:
      - name: wait-database
        image: busybox:latest
        command: ['sh', '-c', 'until nc -z postgres-service.vermeg-db.svc.cluster.local 5432; do echo "DB non prête..."; sleep 2; done; echo "DB prête!"']
      
      - name: wait-gateway
        image: busybox:latest
        command: ['sh', '-c', 'until nc -z api-gateway.vermeg.svc.cluster.local 8080; do echo "Gateway non prêt..."; sleep 2; done; echo "Gateway prêt!"']
      
      containers:
      - name: employee-service
        image: employee-service:latest
        
        ports:
        - containerPort: 8080
          name: http
        
        # ============ LIVENESS PROBE ============
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8080
          
          # Timing
          initialDelaySeconds: 40   # Attendre le démarrage
          timeoutSeconds: 5         # Chaque requête timeout après 5s
          periodSeconds: 10         # Vérifier toutes les 10s
          
          # Seuils
          failureThreshold: 3       # Redémarrer après 3 échecs
          successThreshold: 1       # Suffisant 1 succès pour être OK
        
        # ============ READINESS PROBE ============
        readinessProbe:
          httpGet:
            path: /api/ready
            port: 8080
          
          # Timing
          initialDelaySeconds: 15   # Attendre le démarrage
          timeoutSeconds: 3
          periodSeconds: 5          # Vérifier souvent
          
          # Seuils
          failureThreshold: 2       # Retirer après 2 échecs
          successThreshold: 1       # Ajouter après 1 succès
        
        # ============ STARTUP PROBE (Optionnel) ============
        # Pour applications qui prennent du temps à démarrer
        startupProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
          failureThreshold: 30      # Attendre max 30*10 = 300s
        
        # ============ RESSOURCES ============
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # ============ VARIABLES ============
        env:
        - name: JAVA_OPTS
          value: "-Xmx512m"
        
        envFrom:
        - configMapRef:
            name: vermeg-config
      
      # ============ POLICIES ============
      # Politique de redémarrage
      restartPolicy: Always  # Toujours redémarrer si échoue
      
      # Grâce (temps pour arrêt gracieux)
      terminationGracePeriodSeconds: 30
      
      # Affinity (optionnel)
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - employee-service
              topologyKey: kubernetes.io/hostname
```

### 6.4 Test des Health Checks
**À FAIRE:**
```bash
# 1. Appliquer le deployment
kubectl apply -f kubernetes/employee-service/deployment-with-health-checks.yaml

# 2. Observer les probes
kubectl get pods -n vermeg
kubectl describe pod <pod-name> -n vermeg
# Chercher "Liveness" et "Readiness" dans l'output

# 3. Voir les logs
kubectl logs <pod-name> -n vermeg

# 4. Simuler une failure (kill le process)
kubectl exec -it <pod-name> -n vermeg -- kill 1
# Attendre 30-40s, le pod doit se redémarrer

# 5. Vérifier les redémarrages
kubectl describe pods <pod-name> -n vermeg | grep -i restart
```

### 6.5 Auto-Scaling (Bonus)
Fichier: `kubernetes/employee-service/hpa.yaml`
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: employee-service-hpa
  namespace: vermeg
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: employee-service
  
  minReplicas: 2
  maxReplicas: 10
  
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Scale up quand CPU > 70%
  
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80  # Scale up quand RAM > 80%
  
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
```

---

## 🚀 ÉTAPE 7: DÉPLOYER TOUT ENSEMBLE

### Plan d'Action Récapitulatif

```bash
# 1. Namespaces
kubectl apply -f kubernetes/namespaces.yaml

# 2. ConfigMaps
kubectl apply -f kubernetes/config-maps.yaml

# 3. Base de données
kubectl apply -f kubernetes/database/

# 4. Services (dans le bon ordre!)
kubectl apply -f kubernetes/api-gateway/service.yaml
kubectl apply -f kubernetes/employee-service/service.yaml
kubectl apply -f kubernetes/recruitment-service/service.yaml
kubectl apply -f kubernetes/dashboard/service.yaml

# 5. Déploiements
kubectl apply -f kubernetes/api-gateway/deployment.yaml
kubectl apply -f kubernetes/employee-service/deployment.yaml
kubectl apply -f kubernetes/recruitment-service/deployment.yaml
kubectl apply -f kubernetes/dashboard/deployment.yaml

# 6. Auto-Scaling (optionnel)
kubectl apply -f kubernetes/employee-service/hpa.yaml

# 7. Vérifier tout
kubectl get all -n vermeg
kubectl get all -n vermeg-db
```

### Vérification Finale
```bash
# 1. Tous les pods doivent être "Running"
kubectl get pods -n vermeg
kubectl get pods -n vermeg-db

# 2. Tous les services actifs
kubectl get svc -n vermeg
kubectl get svc -n vermeg-db

# 3. Aucune erreur
kubectl get events -n vermeg
kubectl get events -n vermeg-db

# 4. Accéder aux services
minikube ip
# Ouvrir dans le navigateur:
# - http://<ip>:30380 (API Gateway)
# - http://<ip>:30099 (Security Dashboard)
```

---

## 📊 TABLEAU DES COMMANDES UTILES

```bash
# Navigation
kubectl get pods -n vermeg                          # Lister les pods
kubectl describe pod <nom> -n vermeg                # Détails d'un pod
kubectl logs deployment/<nom> -n vermeg             # Logs
kubectl logs deployment/<nom> -n vermeg --tail=100  # 100 dernières lignes
kubectl logs deployment/<nom> -n vermeg -f          # Logs en temps réel

# Debugging
kubectl exec -it <pod-name> -n vermeg -- /bin/bash  # Terminal dans le pod
kubectl port-forward pod/<pod> 8080:8080 -n vermeg  # Redirection de port
kubectl top nodes                                   # Utilisation nœuds
kubectl top pods -n vermeg                          # Utilisation pods

# Déploiement
kubectl apply -f <fichier.yaml>                     # Appliquer config
kubectl delete -f <fichier.yaml>                    # Supprimer config
kubectl rollout status deployment/<nom> -n vermeg   # Statut déploiement
kubectl rollout undo deployment/<nom> -n vermeg     # Annuler changement

# Events & Status
kubectl get events -n vermeg                        # Événements
kubectl get hpa -n vermeg                           # Auto-scaling
kubectl describe hpa <nom> -n vermeg                # Détails auto-scaling
```

---

## ⚠️ NOTES IMPORTANTES

1. **Images Docker**
   - Les images doivent être disponibles dans registry (Docker Hub, private registry)
   - Pour dev local: `docker build -t employee-service:latest .`

2. **Secrets**
   - JAMAIS mettre de credentials en clair dans YAML!
   - Utiliser `kubectl create secret`

3. **Upgrade de Images**
   ```bash
   kubectl set image deployment/employee-service \
     employee-service=employee-service:v2 -n vermeg
   ```

4. **Logs Persistants**
   - Les logs sont perdus quand le pod meurt
   - Solution: Elasticsearch/Kibana ou Cloud logging

5. **Monitoring**
   - Installer Prometheus pour le monitoring
   - Installer Grafana pour les dashboards

---

## 🎯 PROCHAIN ÉTAPE

Une fois tout déployé:
1. **Ingress** - Exposer avec un seul point d'entrée (URLs)
2. **Certificates** - HTTPS avec Let's Encrypt
3. **Monitoring** - Prometheus + Grafana
4. **Log Aggregation** - ELK Stack ou Splunk
5. **CI/CD** - GitLab CI / GitHub Actions

---

**Commencez par l'ÉTAPE 1 et avancez graduellement! 🚀**
