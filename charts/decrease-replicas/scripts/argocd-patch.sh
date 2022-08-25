#!/bin/bash
kubectl \
  --namespace argocd \
  patch configmap argocd-cm \
  --patch-file /etc/patches/patch-argocd.yaml

kubectl \
  --namespace argocd \
  rollout restart deployment argocd-server
