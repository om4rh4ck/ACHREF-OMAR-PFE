# 📝 KUBERNETES CHEATSHEET - RÉFÉRENCE RAPIDE

**Imprimez ce fichier ou marquez-le comme favori. Vous l'utiliserez constamment.**

---

## 🚀 DÉMARRER

```bash
# Démarrer le cluster
minikube start --driver=docker

# Voir l'état
minikube status
minikube ip                    # Ex: 192.168.49.2

# Arrêter (quand terminé)
minikube stop
minikube delete               # Supprimer tout
```

---

## 📦 CRÉER & DÉPLOYER

```bash
# Appliquer un fichier YAML
kubectl apply -f fichier.yaml
kubectl apply -f repertoire/   # Tous les YAML du dossier

# Appliquer et vérifier
kubectl apply -f namespaces.yaml && kubectl get namespaces

# Supprimer
kubectl delete -f fichier.yaml
kubectl delete pod <nom> -n <namespace>
```

---

## 👀 VOIR LES RESSOURCES

```bash
# Namespaces
kubectl get namespaces
kubectl get ns

# Pods
kubectl get pods -n vermeg              # Dans namespace vermeg
kubectl get pods -n vermeg-db           # Dans namespace vermeg-db
kubectl get pods                        # Dans default namespace
kubectl get pods -A                     # TOUS les namespaces

# Services
kubectl get services -n vermeg
kubectl get svc -n vermeg               # Abrégé

# Volumes
kubectl get pv                          # PersistentVolumes
kubectl get pvc -n vermeg-db            # PersistentVolumeClaims

# ConfigMaps
kubectl get cm -n vermeg                # ConfigMaps

# Deployments
kubectl get deployments -n vermeg

# StatefulSets
kubectl get statefulsets -n vermeg-db
```

---

## 📊 DÉTAILS & INFO

```bash
# Description complète (très utile!)
kubectl describe pod <pod-name> -n vermeg
kubectl describe svc <service-name> -n vermeg
kubectl describe pvc postgres-pvc -n vermeg-db

# Logs (très important pour debug)
kubectl logs <pod-name> -n vermeg
kubectl logs <pod-name> -n vermeg -f      # Suivi en temps réel (Ctrl+C pour arrêter)
kubectl logs <pod-name> -n vermeg --tail=50  # Dernières 50 lignes

# Utilisation ressources
kubectl top nodes                        # CPU/RAM par node
kubectl top pods -n vermeg               # CPU/RAM par pod

# Voir les events (what happened)
kubectl get events -n vermeg
```

---

## 🔧 DEBUG & TERMINAL

```bash
# Accéder au terminal du pod
kubectl exec -it <pod-name> -n vermeg -- /bin/bash
kubectl exec -it deployment/api-gateway -n vermeg -- /bin/bash

# Lancer une commande unique
kubectl exec <pod-name> -n vermeg -- ls -la
kubectl exec postgres-0 -n vermeg-db -- psql -U vermeg_admin -d vermeg_db

# Tester DNS
kubectl exec -it <pod> -n vermeg -- nslookup employee-service.vermeg.svc.cluster.local

# Tester curl
kubectl exec -it <pod> -n vermeg -- curl http://employee-service.vermeg.svc.cluster.local:8080

# Copier des fichiers from/to pod
kubectl cp <pod>:/chemin/fichier ./fichier-local -n vermeg
kubectl cp ./fichier-local <pod>:/chemin/fichier -n vermeg
```

---

## 🔄 MODIFICATION & RESTART

```bash
# Redémarrer un pod (le supprimer, puis il redémarre)
kubectl delete pod <pod-name> -n vermeg

# Mettre à jour une image
kubectl set image deployment/<deployment-name> \
  <container-name>=nouvelleimage:tag -n vermeg

# Voir l'historique des déploiements
kubectl rollout history deployment/<name> -n vermeg

# Rollback à la version précédente
kubectl rollout undo deployment/<name> -n vermeg
```

---

## 🔍 FILTRER & RECHERCHER

```bash
# Services seulement
kubectl get pods -n vermeg --selector=app=api-gateway

# Pods en erreur
kubectl get pods -n vermeg --field-selector=status.phase=Failed

# Voir les labels (pour filtering)
kubectl get pods -n vermeg --show-labels

# Ajouter un label
kubectl label pods <pod-name> environnement=test -n vermeg
```

---

## 📱 ACCÉDER AUX APPLICATIONS

```bash
# Depuis terminal local
minikube service <service-name> -n <namespace>
# Ouvre automatiquement le navigateur!

# Ou manuellement
minikube ip                    # Récupère l'IP
# Puis navigateur: http://IP:PORT

# Port-forward (accès local)
kubectl port-forward pod/<pod-name> 8080:8080 -n vermeg
# Puis: http://localhost:8080
```

---

## 🛠️ CONFIGURATION & ENV

```bash
# Voir les variables d'env d'un pod
kubectl exec <pod-name> -n vermeg -- env

# Voir les ConfigMaps values
kubectl get cm vermeg-config -n vermeg -o yaml

# Éditer une ConfigMap (très dangereux, mais possible)
kubectl edit cm vermeg-config -n vermeg
```

---

## 📊 STATUS & HEALTH

```bash
# Est-ce que le pod tourne?
kubectl get pod <pod-name> -n vermeg
# Status: Running, Pending, Failed, CrashLoopBackOff, ImagePullBackOff

# Pourquoi ça ne tourne pas?
kubectl describe pod <pod-name> -n vermeg
# Chercher section "Events"

# Logs d'erreur
kubectl logs <pod-name> -n vermeg

# Vérifier les probes
kubectl describe pod <pod-name> -n vermeg | grep -A 5 "Probes:"
```

---

## 🔐 PERMISSIONS & ADMIN

```bash
# Voir le compte courant
kubectl config current-context

# Voir la config
kubectl config view

# Voir qui a quel accès (RBAC)
kubectl get rolebindings -n vermeg

# Créer un utilisateur (avancé)
kubectl create serviceaccount mon-user -n vermeg
```

---

## 🗑️ NETTOYAGE & RESET

```bash
# Supprimer TOUS les pods d'un namespace
kubectl delete pods --all -n vermeg

# Supprimer TOUS les deployments
kubectl delete deployments --all -n vermeg

# Supprimer tout dans un namespace
kubectl delete all --all -n vermeg

# Supprimer un namespace entier
kubectl delete namespace vermeg-test
# (Attention: tout dedans est supprimé!)
```

---

## 📈 SCALING & AUTO-SCALING

```bash
# Augmenter les réplicas manuellement
kubectl scale deployment/api-gateway --replicas=5 -n vermeg

# Voir les réplicas actuels
kubectl get deployment -n vermeg

# Auto-scaling (si HPA est installé)
kubectl autoscale deployment/<name> --min=2 --max=5 -n vermeg
kubectl get hpa -n vermeg
```

---

## 🔐 SECRETS

```bash
# Créer un secret
kubectl create secret generic db-password --from-literal=password=mypass -n vermeg

# Voir la liste des secrets
kubectl get secrets -n vermeg

# Accéder à un secret (dangereux!)
kubectl get secret <secret-name> -n vermeg -o yaml
```

---

## 📡 NETWORKING

```bash
# Voir les services et leurs IP
kubectl get svc -n vermeg

# Voir le type de service
kubectl describe svc <service-name> -n vermeg

# Port-forward d'un service
kubectl port-forward svc/api-gateway 8080:8080 -n vermeg

# Tester réseau pod-to-pod
kubectl exec -it <pod1> -n vermeg -- curl <pod2-ip>:8080
```

---

## 🔄 MULTI-NAMESPACE

```bash
# Changer le namespace par défaut
kubectl config set-context --current --namespace=vermeg

# Vérifier le namespace courant
kubectl config view | grep namespace

# Revenez à "default"
kubectl config set-context --current --namespace=default
```

---

## 📋 PRATIQUES UTILES

```bash
# Alias pour gagner du temps
alias k=kubectl
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ke='kubectl exec -it'

# Puis utiliser
k get pods -n vermeg          # Au lieu de kubectl
```

---

## ⚡ COMMANDES CHAÎNÉES UTILES

```bash
# Voir tous les pods en Running
kubectl get pods -n vermeg --field-selector=status.phase=Running

# Supprimer les pods Failed
kubectl delete pods --field-selector=status.phase=Failed -n vermeg

# CPU usage par pod
kubectl top pods -n vermeg --sort-by=cpu

# Pods avec la plus grande RAM
kubectl top pods -n vermeg --sort-by=memory

# List des images utilisées
kubectl get pods -n vermeg -o jsonpath='{.items[*].spec.containers[*].image}'
```

---

## 🚨 ERREURS COURANTES & SOLUTIONS

| Erreur | Cause | Solution |
|--------|-------|----------|
| `ImagePullBackOff` | Image pas trouvée | Vérifier le nom de l'image, le registry |
| `CrashLoopBackOff` | App plante au démarrage | `kubectl logs <pod>` pour voir l'erreur |
| `Pending` | Pas assez de ressources | `kubectl describe pod`, ou arrêter autres pods |
| `Connection refused` | Service pas accessible | Vérifier service existe, port correct |
| `Dns resolution failed` | DNS pas configuré | Tester avec full FQDN: `*.svc.cluster.local` |

---

## 📚 HELP INTÉGRÉ

```bash
kubectl --help                          # Aide générale
kubectl <command> --help                # Aide sur une commande
kubectl explain pods                    # Explique la structure YAML
kubectl api-resources                   # Voir tous les types de ressources
```

---

## 🎯 VOS COMMANDES LES PLUS UTILISÉES

```bash
# These 3 commands = 80% of what you'll use

# 1. Voir tous les pods
kubectl get pods -n vermeg

# 2. Voir les logs pour debug
kubectl logs <pod-name> -n vermeg -f

# 3. Describe pour les infos détaillées
kubectl describe pod <pod-name> -n vermeg
```

---

## 📱 VERSION COURTE (Copy-Paste Ready)

```bash
# Setup
minikube start --driver=docker
minikube ip

# Deploy
kubectl apply -f kubernetes/namespaces.yaml
kubectl apply -f kubernetes/config-maps.yaml
kubectl apply -f kubernetes/database/
kubectl apply -f kubernetes/api-gateway/
kubectl apply -f kubernetes/employee-service/
kubectl apply -f kubernetes/recruitment-service/
kubectl apply -f kubernetes/dashboard/

# Check
kubectl get pods -n vermeg
kubectl get svc -n vermeg
kubectl logs deployment/api-gateway -n vermeg
kubectl describe pod <pod-name> -n vermeg

# Access
minikube service api-gateway -n vermeg     # Port 30380
minikube service security-dashboard -n vermeg  # Port 30099

# Cleanup
kubectl delete -f kubernetes/
minikube stop
```

---

## 💾 SAUVEGARDER CET FICHIER

Cette cheatsheet est votre ami constant. Imprimez-la, marquez-la, référencez-y constamment!

---

**🚀 HAPPY KUBERNETES! May your pods run forever! 🚀**

---

## Index des Sections

- 🚀 Démarrer
- 📦 Créer & Déployer
- 👀 Voir les ressources
- 📊 Détails & Info
- 🔧 Debug & Terminal
- 🔄 Modification & Restart
- 🔍 Filtrer & Rechercher
- 📱 Accéder aux applications
- 🛠️ Configuration & ENV
- 📊 Status & Health
- 🔐 Permissions & Admin
- 🗑️ Nettoyage & Reset
- 📈 Scaling & Auto-scaling
- 🔐 Secrets
- 📡 Networking
- 🔄 Multi-namespace
- 📋 Pratiques utiles
- ⚡ Commandes chaînées utiles
- 🚨 Erreurs courantes
- 📚 Help intégré
