#!/bin/bash

# Point to the internal API server hostname
APISERVER="https://kubernetes.default.svc"

# Path to ServiceAccount token
SERVICEACCOUNT="/var/run/secrets/kubernetes.io/serviceaccount"

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

log() {
  MESSAGE=$1
  DATETIME=$(date +"%Y-%m-%d %H:%M:%S")
  printf '[%s] %s\n' "${DATETIME}" "${MESSAGE}"
}

log "start"
echo ""

NAMESPACE_FILTER="${NAMESPACE}|kube-*|^local-|^argocd|cert-*|external-secrets|gatekeeper-system|^istio|keda|prometheus|newrelic"

kubectl get hpa \
  --all-namespaces \
  --output jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.minReplicas} {.spec.maxReplicas}{"\n"}{end}' \
| grep -vE "${NAMESPACE_FILTER}" \
| while read LINE; do
  NAMESPACE=$(awk '{ print $1 }' <<< "${LINE}")
  HPA_NAME=$(awk '{ print $2 }' <<< "${LINE}")
  HPA_MIN_PODS=$(awk '{ print $3 }' <<< "${LINE}")
  HPA_MAX_PODS=$(awk '{ print $4 }' <<< "${LINE}")

  if [ ${HPA_MIN_PODS} -gt 1 ] || [ ${HPA_MAX_PODS} -gt 1 ]; then
    echo "[${NAMESPACE}] [hpa]: ${HPA_NAME} (${HPA_MIN_PODS}/${HPA_MAX_PODS})"
    kubectl \
      --namespace ${NAMESPACE?} \
      patch hpa ${HPA_NAME} \
      --patch '{"spec": {"minReplicas" : 1, "maxReplicas" : 1}}' &> /dev/null
  fi
done

echo ""

kubectl get deployments \
  --all-namespaces \
  --output jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.replicas}{"\n"}{end}' \
| grep -vE "${NAMESPACE_FILTER}" \
| while read LINE; do
  NAMESPACE=$(awk '{ print $1 }' <<< "${LINE}")
  DEPLOYMENT_NAME=$(awk '{ print $2 }' <<< "${LINE}")
  DEPLOYMENT_REPLICAS=$(awk '{ print $3 }' <<< "${LINE}")

  if [ ${DEPLOYMENT_REPLICAS} -gt 1 ]; then
    echo "[${NAMESPACE}] [deployment]: ${DEPLOYMENT_NAME} (${DEPLOYMENT_REPLICAS})"
    kubectl \
      --namespace ${NAMESPACE?} \
      scale deployment ${DEPLOYMENT_NAME?} \
      --replicas 1 &> /dev/null
  fi
done

echo ""
log "finish"
echo ""
