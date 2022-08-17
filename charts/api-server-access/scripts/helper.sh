#!/bin/bash

kubectl auth can-i list deployments \
  --namespace default \
  --as system:serviceaccount:default:api-server-access

kubectl auth can-i list horizontalpodautoscalers \
  --namespace default \
  --as system:serviceaccount:default:api-server-access

kubectl create namespace operations

kubectl create deployment \
  --image=nginx \
  nginx

kubectl autoscale deployment nginx \
  --cpu-percent=50 \
  --min=3 \
  --max=5

kubectl get hpa,deploy,pods,cronjob,job | grep -vE "^kube-|^local"

kubectl \
  --namespace default \
  patch hpa nginx \
  --patch '{"spec": {"minReplicas" : 3, "maxReplicas" : 5}}'

helm install \
  --namespace operations \
  --create-namespace \
  api-server-access ${HOME}/git/helm/charts/api-server-access

kubectl \
  --namespace operations \
  logs \
  --selector app=api-server-access
