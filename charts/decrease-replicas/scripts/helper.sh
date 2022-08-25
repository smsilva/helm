#!/bin/bash

# Deployment
kubectl \
  --namespace default \
  create deployment \
  --image=nginx \
  nginx \
  --replicas 2

# Horizonta Pod Autoscale
kubectl \
  --namespace default \
  autoscale deployment nginx \
  --cpu-percent=50 \
  --min=3 \
  --max=5

# Follow
watch -n 3 'kubectl \
  --namespace default \
  get hpa,deploy,pods \
| grep -vE "^kube-|^local"'

# Follow decrease-replicas
watch -n 3 'kubectl \
  --namespace decrease-replicas \
  get configmap,cronjob,jobs,pods \
  | grep -v "kube-root-ca"'

# Install decrease-replicas
helm upgrade \
  --install \
  --namespace decrease-replicas \
  --create-namespace \
  decrease-replicas ${HOME}/git/helm/charts/decrease-replicas

# Logs
kubectl \
  --namespace decrease-replicas \
  logs \
  --selector app=decrease-replicas

# Uninstall
helm \
  --namespace decrease-replicas \
  uninstall decrease-replicas

# Patch
kubectl \
  --namespace default \
  patch hpa nginx \
  --patch '{"spec": {"minReplicas" : 3, "maxReplicas" : 5}}'

# Scale Deploy nginx
kubectl \
  --namespace default \
  scale deployment nginx \
  --replicas 3
