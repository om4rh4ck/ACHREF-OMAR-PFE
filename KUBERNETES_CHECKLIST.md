# ✅ KUBERNETES DE A À Z - CHECKLIST DE COMPRÉHENSION

## 🎯 Avant de commencer: Vérifiez votre compréhension

---

## PARTIE 1: CONCEPTS FONDAMENTAUX

### 1.1 - Kubernetes: C'est quoi?
- [ ] Kubernetes = Orchestrateur de conteneurs
- [ ] Gère déploiement, scaling, et networking automatiquement
- [ ] Plus riche que Docker Compose
- [ ] Prêt pour la production

**Questions de vérification:**
- K8s résout quel problème? → Gestion automatique de services
- Différence vs Docker? → K8s automatise tout, Docker c'est manuel

---

### 1.2 - Concepts Clés
- [ ] **Pod** = Plus petite unité (1+ conteneurs partagent ressources)
- [ ] **Node** = Machine physique/VM qui exécute les pods
- [ ] **Cluster** = Ensemble de nodes
- [ ] **Namespace** = Partitions logiques du cluster
- [ ] **Service** = Accès réseau aux pods (DNS + LB)
- [ ] **Ingress** = Routage HTTP pour l'extérieur

**Questions de vérification:**
- Un pod contient combien de conteneurs AU MINIMUM? → 1 minimum
- Peut avoir 2? → Oui
- Tous les conteneurs dans un pod partagent quel? → IP, ports, storage

---

### 1.3 - Ressources & Stockage
- [ ] **Deployment** = Replica set qui veille à réplicates
- [ ] **StatefulSet** = Pour applications stateful (bases de données)
- [ ] **PersistentVolume (PV)** = Stockage physique
- [ ] **PersistentVolumeClaim (PVC)** = Demande de stockage
- [ ] **ConfigMap** = Variables d'environnement en une constante
- [ ] **Secret** = Variables sensibles (chiffrées)

**Questions de vérification:**
- Les données survivent si pod meurt? → OUI si PVC
- PostgreSQL doit utiliser StatefulSet ou Deployment? → StatefulSet
- Où put: Variables d'env? → ConfigMap ou Secret

---

## PARTIE 2: ARCHITECTURE VERMEG

### 2.1 - Namespaces
- [ ] **vermeg** = Microservices (API gateway, services)
- [ ] **vermeg-db** = Bases de données (PostgreSQL)
- [ ] Isolation: Services vermeg NE voient PAS vermeg-db directement
- [ ] Communication: DNS service discovery

**Questions de vérification:**
- Pourquoi 2 namespaces? → Séparation de concerns
- Peut-on avoir les services et la DB dans un? → OUI (mais pas recommandé)

### 2.2 - Services
- [ ] **api-gateway** (NodePort 30380) = Entrée principale
- [ ] **employee-service** (ClusterIP) = Interne seulement
- [ ] **recruitment-service** (ClusterIP) = Interne seulement
- [ ] **security-dashboard** (NodePort 30099) = Accès externe
- [ ] **postgres-service** (Headless) = Pour StatefulSet

**Questions de vérification:**
- Qui peut accéder à employee-service de l'extérieur? → Personne (ClusterIP)
- Comment api-gateway l'appelle? → DNS: employee-service.vermeg.svc.local
- Qui peut accéder au dashboard depuis le navigateur? → Minikube IP:30099

---

### 2.3 - Données
- [ ] **PostgreSQL** stocke toutes les données persistentes
- [ ] **PVC (10Gi)** = Stockage persistant
- [ ] **Données survivent** redémarrage pod/node/cluster
- [ ] **Backup local** sur host minikube

---

## PARTIE 3: INSTALLATION WSL + KUBERNETES

### 3.1 - WSL Setup
- [ ] WSL 2 installé (pas WSL 1)
- [ ] Une distro Linux (Ubuntu) dans WSL
- [ ] WSL est le default (wsl --set-default-version 2)
- [ ] Terminal WSL fonctionne (wsl)

**Commandes vérification:**
```bash
wsl --list --verbose
# Doit montrer: * Ubuntu    Running    2
```

---

### 3.2 - Docker Setup
- [ ] Docker installé dans WSL
- [ ] Service Docker tourne
- [ ] Utilisateur dans groupe docker
- [ ] docker ps marche

**Commandes vérification:**
```bash
docker --version
docker ps
# Pas d'errors
```

---

### 3.3 - Kubernetes Setup
- [ ] kubectl installé
- [ ] minikube installé
- [ ] Cluster minikube démarré
- [ ] kubectl peut communiquer

**Commandes vérification:**
```bash
minikube status
# cluster: Running
# minikube: Running

kubectl get nodes
# 1 node "minikube"
```

---

## PARTIE 4: DÉPLOIEMENT

### 4.1 - Namespaces
- [ ] Fichier: kubernetes/namespaces.yaml créé
- [ ] Contient: vermeg et vermeg-db
- [ ] Appliqué: kubectl apply -f kubernetes/namespaces.yaml
- [ ] Vérification: kubectl get namespaces

---

### 4.2 - ConfigMaps
- [ ] Fichier: kubernetes/config-maps.yaml créé
- [ ] Contient: vermeg-config et vermeg-db-config
- [ ] Variables DATABASE_HOST, PORT, etc
- [ ] Appliqué et visible: kubectl get cm -n vermeg

---

### 4.3 - PostgreSQL
- [ ] PV créé (10Gi)
- [ ] PVC lié au PV
- [ ] Service: postgres-service (Headless)
- [ ] StatefulSet: postgres pod
- [ ] Pod en Running: kubectl get pods -n vermeg-db

**Vérification connection:**
```bash
kubectl exec -it postgres-0 -n vermeg-db -- psql -U vermeg_admin -d vermeg_db
```

---

### 4.4 - Microservices
- [ ] **api-gateway** (2 replicas)
  - [ ] Deployment créé
  - [ ] Service NodePort 30380 créé
  - [ ] 2 pods en Running

- [ ] **employee-service** (2 replicas)
  - [ ] Deployment créé
  - [ ] Service ClusterIP créé
  - [ ] 2 pods en Running

- [ ] **recruitment-service** (2 replicas)
  - [ ] Deployment créé
  - [ ] Service ClusterIP créé
  - [ ] 2 pods en Running

---

### 4.5 - Security Dashboard
- [ ] Deployment créé
- [ ] Service NodePort 30099
- [ ] Pod en Running
- [ ] Accessible: http://minikube-ip:30099

**Vérification:**
```bash
minikube ip
# Exemple: 192.168.49.2
# Ouvrir navigateur: http://192.168.49.2:30099
```

---

## PARTIE 5: HEALTH CHECKS

### 5.1 - Liveness Probe
- [ ] Configuré dans deployment
- [ ] URL: /api/health
- [ ] Interval: 10 secondes
- [ ] Timeout: 5 secondes
- [ ] Failure threshold: 3 échecs = redémarrage
- [ ] Pod redémarre si l'application plante

**Vérification:**
```bash
# Le pod doit redémarrer si le serveur s'arrête
kubectl exec -it <pod> -n vermeg -- kill 1
# Attendre 30s, pod doit redémarrer
```

---

### 5.2 - Readiness Probe
- [ ] Configuré dans deployment
- [ ] URL: /api/ready (ou /api/health)
- [ ] Interval: 5 secondes
- [ ] Failure threshold: 2 échecs = retirer du service
- [ ] Service continue de routager vers autres pods

---

### 5.3 - Verification Probes
```bash
# Voir les probes dans un pod
kubectl describe pod <pod-name> -n vermeg | grep -A 5 "Probes:"

# Doit montrer:
# Liveness:     http-get http://:8080/api/health delay=30s timeout=5s
# Readiness:    http-get http://:8080/api/health delay=10s timeout=3s
```

---

## PARTIE 6: NETWORKING

### 6.1 - Service Discovery Interne
- [ ] Services ont un DNS automatique
- [ ] Pattern: service-name.namespace.svc.cluster.local
- [ ] Kube-DNS résout automatiquement

**Exemples VERMEG:**
```
employee-service.vermeg.svc.cluster.local:8080
recruitment-service.vermeg.svc.cluster.local:8080
postgres-service.vermeg-db.svc.cluster.local:5432
api-gateway.vermeg.svc.cluster.local:8080
```

**Test de connection:**
```bash
# Depuis un pod, testern résolution DNS
kubectl exec -it <api-gateway-pod> -n vermeg -- \
  curl http://employee-service.vermeg.svc.cluster.local:8080/api/health
# Doit marcher même si pod a changé!
```

---

### 6.2 - Accès Externe
- [ ] NodePort: 30380 → api-gateway:8080
- [ ] NodePort: 30099 → dashboard:8099
- [ ] Minikube IP: 192.168.49.2 (exemple)
- [ ] URL: http://192.168.49.2:30380

**Vérification:**
```bash
minikube service api-gateway -n vermeg
# Ouvre automatiquement dans le browser
```

---

## PARTIE 7: VOLUMES & PERSISTANCE

### 7.1 - PersistentVolume
- [ ] Défini une seule fois dans le cluster
- [ ] Stockage physique (/mnt/data/postgres)
- [ ] 10Gi d'espace
- [ ] AccessMode: ReadWriteOnce (un pod à la fois)

---

### 7.2 - PersistentVolumeClaim
- [ ] Demande d'utilisation du PV
- [ ] Liée au PV automatiquement
- [ ] Mont: /var/lib/postgresql/data
- [ ] Les données restent même si pod meurt

**Vérification:**
```bash
kubectl get pv
# Doit montrer postgres-pv

kubectl get pvc -n vermeg-db
# Doit montrer postgres-pvc

# Ajouter données
kubectl exec -it postgres-0 -n vermeg-db -- psql -c "CREATE TABLE test (id int);"

# Supprimer le pod
kubectl delete pod postgres-0 -n vermeg-db

# Attendre redémarrage
kubectl get pods -n vermeg-db

# Données sont encore là!
kubectl exec -it postgres-0 -n vermeg-db -- psql -c "\\dt"
# Doit montrer la table test
```

---

## PARTIE 8: DEBUGGING & COMMANDS

### 8.1 - Commandes de Vérification
- [ ] kubectl get pods -n vermeg
  → Voir tous les pods et statut
- [ ] kubectl get svc -n vermeg
  → Voir tous les services
- [ ] kubectl get pvc -n vermeg-db
  → Voir les volumes

---

### 8.2 - Commandes De Debugging
- [ ] kubectl logs <pod-name> -n vermeg
  → Voir les logs du pod
- [ ] kubectl logs <pod> -n vermeg -f
  → Voir logs en temps réel (tail -f)
- [ ] kubectl describe pod <pod> -n vermeg
  → Voir TOUS les détails: config, events, conditions
- [ ] kubectl exec -it <pod> -n vermeg -- /bin/bash
  → Terminal dans le pod

---

### 8.3 - Commandes d'Erreurs
```bash
# Pod bloqué au démarrage?
kubectl describe pod <name> -n vermeg
# Chercher "Events" section

# Liveness probe échoue?
kubectl logs pod/<name> -n vermeg

# Service ne résout pas?
kubectl exec -it pod/<name> -n vermeg -- nslookup employee-service.vermeg.svc.cluster.local

# Pod consomme trop de RAM?
kubectl top pods -n vermeg
```

---

## 🎯 FINAL CHECKLIST - Everything Working?

### Étape 1: Infrastructure
- [ ] `minikube status` montre tout Running
- [ ] `kubectl get nodes` montre 1 nœud
- [ ] `kubectl get namespaces` montre vermeg et vermeg-db

### Étape 2: Configuration
- [ ] `kubectl get cm -n vermeg` montre vermeg-config
- [ ] `kubectl get cm -n vermeg-db` montre vermeg-db-config

### Étape 3: Database
- [ ] `kubectl get pv` montre postgres-pv
- [ ] `kubectl get pvc -n vermeg-db` montre postgres-pvc
- [ ] `kubectl get pods -n vermeg-db` montre postgres-0 Running

### Étape 4: Services
- [ ] `kubectl get pods -n vermeg` montre
  - 2x api-gateway pods (Running)
  - 2x employee-service pods (Running)
  - 2x recruitment-service pods (Running)
  - 1x security-dashboard pod (Running)

- [ ] `kubectl get svc -n vermeg` montre
  - api-gateway (NodePort 30380)
  - employee-service (ClusterIP)
  - recruitment-service (ClusterIP)
  - security-dashboard (NodePort 30099)

### Étape 5: Networking
- [ ] `minikube ip` vous donne une IP (ex: 192.168.49.2)
- [ ] Navigateur: http://192.168.49.2:30380 → API Gateway marche
- [ ] Navigateur: http://192.168.49.2:30099 → Dashboard marche

### Étape 6: Health Checks
- [ ] `kubectl describe pod <api-gateway-pod> -n vermeg | grep -A 5 "Probes:"`
  → Montre Liveness et Readiness configurées

- [ ] Terminez manuellement un pod:
  ```bash
  kubectl exec -it <pod> -n vermeg -- kill 1
  ```
  → Pod redémarre automatiquement après ~30s

### Étape 7: Communication
- [ ] Depuis un pod, testez DNS:
  ```bash
  kubectl exec -it deployment/api-gateway -n vermeg -- \
    curl http://employee-service.vermeg.svc.cluster.local:8080/api/health
  ```
  → Doit répondre avec 200 OK

### Étape 8: Logs
- [ ] `kubectl logs deployment/api-gateway -n vermeg -- tail=20`
  → Montre des logs sanà erreurs
- [ ] Aucun message d'erreur CrashLoopBackOff

### Étape 9: Ressources
- [ ] `kubectl top nodes`
  → CPU et RAM disponibles
- [ ] `kubectl top pods -n vermeg`
  → Utilisation par pod (requests < limits)

---

## 🔄 SI QUELQUE CHOSE NE MARCHE PAS

**Pod ne démarre pas?**
```bash
kubectl describe pod <name> -n vermeg
# Chercher "Events" à bottleneck
# Commun: ImagePullBackOff, CrashLoopBackOff
```

**Service ne résout pas?**
```bash
kubectl exec -it <pod> -n vermeg -- nslookup employee-service
# Si erreur: DNS problems
```

**Pod consomme trop de resources?**
```bash
kubectl top pods -n vermeg
# Augmentez limits dans deployment
```

**Données perdues après redémarrage?**
```bash
# Vérifier PVC existe
kubectl get pvc -n vermeg-db
# Vérifier pod monte le volume
kubectl describe pod postgres-0 -n vermeg-db | grep -A 5 "Mounts"
```

---

## 📚 RESSOURCES COMPLÉMENTAIRES

**Dans ce projet:**
- KUBERNETES_README.md - Table des matières
- KUBERNETES_ARCHITECTURE.md - Diagrams visuels
- KUBERNETES_GUIDE.md - Guide complet détaillé
- KUBERNETES_QUICK_START.md - Pas à pas d'action

**Officiellement:**
- https://kubernetes.io/docs/ - Doc officielle K8s
- https://kubernetes.io/docs/tutorials/ - Tutoriels
- https://minikube.sigs.k8s.io/ - Minikube docs

---

## 🎓 PROGRESSION D'APPRENTISSAGE

```
Level 1: Débutant
├─ Comprendre Namespace, Pod, Service
├─ Déployer une application simple
└─ Voir les logs

Level 2: Intermédiaire
├─ Health checks & auto-restart
├─ Volumes persistants
├─ Replication (multiple pods)
├─ Communication entre services
└─ Debugging complet

Level 3: Avancé
├─ Auto-scaling (HPA)
├─ Ingress & HTTPS
├─ StatefulSets avancés
├─ Network Policies
├─ RBAC & Security
└─ Monitoring (Prometheus)

Level 4: Expert
├─ Operators
├─ Custom resources
├─ Multi-cluster
├─ Service mesh (Istio)
└─ Production hardening
```

---

## ✨ FÉLICITATIONS!

Si vous avez coché toutes les cases ci-dessus, vous:

✅ Comprenez l'architecture Kubernetes  
✅ Pouvez déployer une application complète  
✅ Savez gérer les volumes persistants  
✅ Avez configuré health checks et auto-restart  
✅ Savez communiquer entre microservices  
✅ Pouvez déboguer et corriger les problèmes  
✅ Êtes prêt pour des architectures plus complexes  

---

**VOUS ÊTES MAINTENANT UN INGÉNIEUR KUBERNETES! 🎉**

Prochaines étapes optionnelles:
1. Ingress avec HTTPS
2. Monitoring avec Prometheus + Grafana
3. Logging avec ELK Stack
4. CI/CD avec GitLab CI ou GitHub Actions
5. Production deployment (multi-node, high availability)

---

**KEEP LEARNING, KEEP DEPLOYING! 🚀**
