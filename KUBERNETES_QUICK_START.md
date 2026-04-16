# 🎯 GUIDE D'ACTION RAPIDE - DÉMARRAGE KUBERNETES

## START HERE! Suivez ces étapes dans l'ordre 👇

---

## ✅ ÉTAPE 1: VÉRIFIER WSL & INSTALLATION (5 min)

### 1.1 Terminal PowerShell (Admin)
```powershell
# Vérifier WSL 2
wsl --list --verbose

# Résultat devrait montrer: * Ubuntu    Running         2
# Si WSL 1, upgrader à WSL 2:
wsl --set-default-version 2
```

### 1.2 Terminal WSL (Ubuntu)
```bash
# Rentrer dans WSL
wsl

# Vérifier Docker
docker --version
docker ps

# Si erreur, installer Docker (voir KUBERNETES_GUIDE.md section 1.2)
```

**✅ VOUS AVEZ RÉUSSI SI:**
- Docker répond "Docker version X.X.X"
- Pas d'erreurs

---

## ✅ ÉTAPE 2: INSTALLER KUBERNETES (10 min)

### 2.1 Dans WSL Terminal
```bash
# Installer kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

kubectl version --client
```

### 2.2 Installer Minikube
```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-x86_64
sudo install minikube-linux-x86_64 /usr/local/bin/minikube
rm minikube-linux-x86_64

minikube version
```

### 2.3 Démarrer Minikube
```bash
minikube start --driver=docker

# Attendre ~1-2 minutes
# Résultat: ✅ Done! kubectl is now configured to use "minikube" by default

minikube status
```

**✅ VOUS AVEZ RÉUSSI SI:**
```
minikube: Running
cluster: Running
kubectl: Properly configured
```

---

## ✅ ÉTAPE 3: CRÉER LA STRUCTURE KUBERNETES (5 min)

### 3.1 Dans VS Code (Terminal)
```bash
# Eneter dans le projet
cd /path/to/SIRH-PFE-VERMEG-main-main

# Créer la structure
mkdir -p kubernetes/{employee-service,recruitment-service,api-gateway,dashboard,database}
```

### 3.2 Structure finale
```
kubernetes/
├── namespaces.yaml
├── config-maps.yaml
├── employee-service/
│   ├── deployment.yaml
│   └── service.yaml
├── recruitment-service/
│   ├── deployment.yaml
│   └── service.yaml
├── api-gateway/
│   ├── deployment.yaml
│   └── service.yaml
├── dashboard/
│   ├── deployment.yaml
│   └── service.yaml
└── database/
    ├── statefulset.yaml
    ├── service.yaml
    ├── pvc.yaml
    └── pv.yaml
```

---

## ✅ ÉTAPE 4: CRÉER NAMESPACES (3 min)

### 📄 Fichier: kubernetes/namespaces.yaml
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: vermeg

---
apiVersion: v1
kind: Namespace
metadata:
  name: vermeg-db
```

### Appliquer:
```bash
cd /path/to/kubernetes
kubectl apply -f namespaces.yaml

# Vérifier
kubectl get namespaces
```

**Résultat attendu:**
```
NAME              STATUS   AGE
vermeg            Active   10s
vermeg-db         Active   10s
```

---

## ✅ ÉTAPE 5: CRÉER CONFIGMAPS (3 min)

### 📄 Fichier: kubernetes/config-maps.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vermeg-config
  namespace: vermeg
data:
  ENVIRONMENT: "production"
  DATABASE_HOST: "postgres-service.vermeg-db.svc.cluster.local"
  DATABASE_PORT: "5432"
  DATABASE_NAME: "vermeg_db"

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

### Appliquer:
```bash
kubectl apply -f config-maps.yaml

# Vérifier
kubectl get configmaps -n vermeg
kubectl get configmaps -n vermeg-db
```

---

## ✅ ÉTAPE 6: DÉPLOYER BASE DE DONNÉES (5 min)

### 📄 Fichier: kubernetes/database/pv.yaml
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: "/mnt/data/postgres"
```

### 📄 Fichier: kubernetes/database/pvc.yaml
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
```

### 📄 Fichier: kubernetes/database/service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: vermeg-db
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

### 📄 Fichier: kubernetes/database/statefulset.yaml
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
        
        env:
        - name: POSTGRES_DB
          value: "vermeg_db"
        - name: POSTGRES_USER
          value: "vermeg_admin"
        - name: POSTGRES_PASSWORD
          value: "vermeg_secure_pwd_123"
        
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        
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
  
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

### Appliquer:
```bash
kubectl apply -f kubernetes/database/pv.yaml
kubectl apply -f kubernetes/database/pvc.yaml
kubectl apply -f kubernetes/database/service.yaml
kubectl apply -f kubernetes/database/statefulset.yaml

# Vérifier (attendre ~30 secondes)
kubectl get pods -n vermeg-db
kubectl get pvc -n vermeg-db

# Doit montrer:
# NAME      READY   STATUS    RESTARTS   AGE
# postgres-0   1/1     Running   0          1m
```

---

## ✅ ÉTAPE 7: DÉPLOYER API GATEWAY (5 min)

### 📄 Fichier: kubernetes/api-gateway/deployment.yaml
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
        imagePullPolicy: IfNotPresent
        
        ports:
        - containerPort: 8080
        
        envFrom:
        - configMapRef:
            name: vermeg-config
        
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 10
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          failureThreshold: 2
        
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### 📄 Fichier: kubernetes/api-gateway/service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: vermeg
spec:
  type: NodePort
  selector:
    app: api-gateway
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30380
```

### Appliquer:
```bash
kubectl apply -f kubernetes/api-gateway/deployment.yaml
kubectl apply -f kubernetes/api-gateway/service.yaml

# Vérifier (attendre ~30 secondes)
kubectl get pods -n vermeg
kubectl get svc -n vermeg

# Doit montrer 2 pods api-gateway en Running
```

---

## ✅ ÉTAPE 8: DÉPLOYER EMPLOYEE SERVICE (5 min)

### 📄 Fichier: kubernetes/employee-service/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: employee-service
  namespace: vermeg
spec:
  replicas: 2
  selector:
    matchLabels:
      app: employee-service
  
  template:
    metadata:
      labels:
        app: employee-service
    spec:
      initContainers:
      - name: wait-for-db
        image: busybox:1.35
        command: ['sh', '-c', 'until nc -z postgres-service.vermeg-db.svc.cluster.local 5432; do echo "Attendre DB..."; sleep 2; done']
      
      containers:
      - name: employee-service
        image: employee-service:latest
        imagePullPolicy: IfNotPresent
        
        ports:
        - containerPort: 8080
        
        envFrom:
        - configMapRef:
            name: vermeg-config
        
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          failureThreshold: 3
        
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          failureThreshold: 2
        
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### 📄 Fichier: kubernetes/employee-service/service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: employee-service
  namespace: vermeg
spec:
  type: ClusterIP
  selector:
    app: employee-service
  ports:
  - port: 8080
    targetPort: 8080
```

### Appliquer:
```bash
kubectl apply -f kubernetes/employee-service/deployment.yaml
kubectl apply -f kubernetes/employee-service/service.yaml

# Vérifier
kubectl get pods -n vermeg
```

---

## ✅ ÉTAPE 9: DÉPLOYER RECRUITMENT SERVICE (5 min)

### Même pattern que Employee Service!
Créer:
- `kubernetes/recruitment-service/deployment.yaml`
- `kubernetes/recruitment-service/service.yaml`

Changer `employee-service` → `recruitment-service` dans les noms

---

## ✅ ÉTAPE 10: DÉPLOYER SECURITY DASHBOARD (5 min)

### 📄 Fichier: kubernetes/dashboard/deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: security-dashboard
  namespace: vermeg
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
        
        command:
        - /bin/sh
        - -c
        - |
          cd /app
          npm install --production
          node security-dashboard-server.js
        
        volumeMounts:
        - name: dashboard-code
          mountPath: /app
        
        env:
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
        emptyDir: {}
```

### 📄 Fichier: kubernetes/dashboard/service.yaml
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
```

### Appliquer:
```bash
kubectl apply -f kubernetes/dashboard/deployment.yaml
kubectl apply -f kubernetes/dashboard/service.yaml

# Vérifier
kubectl get pods -n vermeg
```

---

## ✅ ÉTAPE FINALE: VÉRIFICATION COMPLÈTE

```bash
# 1. Tous les pods
kubectl get pods -n vermeg
kubectl get pods -n vermeg-db

# Résultat: TOUS les pods doivent être "Running"

# 2. Tous les services
kubectl get svc -n vermeg
kubectl get svc -n vermeg-db

# 3. Aucune erreur
kubectl get events -n vermeg | head -20

# 4. Obtenir l'IP de Minikube
minikube ip
# Exemple: 192.168.49.2

# 5. Accéder à votre application
# API Gateway: http://192.168.49.2:30380
# Security Dashboard: http://192.168.49.2:30099
# Database: 192.168.49.2:30432 (externe)
```

---

## 🐛 DEBUGGING EN CAS D'ERREUR

```bash
# Voir les logs d'un pod
kubectl logs deployment/api-gateway -n vermeg
kubectl logs pod/<pod-name> -n vermeg
kubectl logs deployment/api-gateway -n vermeg -f  # Temps réel

# Décrire un pod (voir tous les détails)
kubectl describe pod/<pod-name> -n vermeg

# Entrer dans un pod pour tester
kubectl exec -it deployment/api-gateway -n vermeg -- /bin/bash

# Redirection de port (accéder sans NodePort)
kubectl port-forward svc/api-gateway 8080:8080 -n vermeg

# Les events (décrit ce qui se passe)
kubectl get events -n vermeg
kubectl get events -n vermeg-db

# Supprimer et recommencer
kubectl delete deployment api-gateway -n vermeg
kubectl delete svc api-gateway -n vermeg
```

---

## 📊 COMMANDES UTILES À MÉMORISER

```bash
# Lister
kubectl get pods -n vermeg
kubectl get svc -n vermeg
kubectl get pvc -n vermeg-db

# Décrire
kubectl describe pod <nom> -n vermeg
kubectl describe svc <nom> -n vermeg

# Logs
kubectl logs <pod> -n vermeg
kubectl logs <pod> -n vermeg -f

# Exec
kubectl exec -it <pod> -n vermeg -- /bin/bash
```

---

## 🎯 RÉSUMÉ DE VOTRE PROGRESSION

| Étape | Tâche | Statut |
|-------|-------|--------|
| 1 | WSL & Docker | À FAIRE |
| 2 | Kubernetes & Minikube | À FAIRE |
| 3 | Structure dossiers | À FAIRE |
| 4 | Namespaces | À FAIRE |
| 5 | ConfigMaps | À FAIRE |
| 6 | Base de données | À FAIRE |
| 7 | API Gateway | À FAIRE |
| 8 | Employee Service | À FAIRE |
| 9 | Recruitment Service | À FAIRE |
| 10 | Security Dashboard | À FAIRE |

---

## 📖 POUR PLUS DE DÉTAILS

Consultez `KUBERNETES_GUIDE.md` pour:
- Explications détaillées
- Exemples avancés
- Health checks complets
- Auto-scaling
- Ingress & HTTPS
- Monitoring & Logging

---

**🚀 COMMENCEZ PAR L'ÉTAPE 1 ET ALLEZ GRADUELLEMENT!**

Chaque étape devrait prendre ~5-10 minutes. N'hésitez pas si vous avez des questions!
