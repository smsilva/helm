#!/bin/bash

# POD Health Check
touch /tmp/healthy

# Accessing the Kubernetes API from a Pod
# https://kubernetes.io/docs/tasks/run-application/access-api-from-pod/

# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc

# Path to ServiceAccount token
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

MESSAGE=$(printf '[%s] %s ' "$(date +"%Y-%m-%d %H:%M:%S %:z")" "decrease execution")

echo "${MESSAGE}"
echo ""

NAMESPACE_FILTER="api-server-access|kube-*|^local-|^argocd|cert-*|external-secrets|gatekeeper-system|^istio|keda|prometheus|newrelic"

kubectl get hpa --all-namespaces --output jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.minReplicas} {.spec.maxReplicas}{"\n"}{end}' | grep -vE "${NAMESPACE_FILTER}" | while read LINE; do
  NAMESPACE=$(awk '{ print $1 }' <<< "${LINE}")
  HPA_NAME=$(awk '{ print $2 }' <<< "${LINE}")
  HPA_MIN_PODS=$(awk '{ print $3 }' <<< "${LINE}")
  HPA_MAX_PODS=$(awk '{ print $4 }' <<< "${LINE}")

  if [ ${HPA_MIN_PODS} -gt 1 ] || [ ${HPA_MAX_PODS} -gt 1 ]; then
    echo "decrease [hpa]: ${NAMESPACE}/${HPA_NAME}/${HPA_MIN_PODS}/${HPA_MAX_PODS}"
    kubectl -n ${NAMESPACE?} patch hpa ${HPA_NAME} --patch '{"spec": {"minReplicas" : 1, "maxReplicas" : 1}}'
  fi
done

kubectl get deployments --all-namespaces --output jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name} {.spec.replicas}{"\n"}{end}' | grep -vE "${NAMESPACE_FILTER}" | while read LINE; do
  NAMESPACE=$(awk '{ print $1 }' <<< "${LINE}")
  DEPLOYMENT_NAME=$(awk '{ print $2 }' <<< "${LINE}")
  DEPLOYMENT_REPLICAS=$(awk '{ print $3 }' <<< "${LINE}")

  if [ ${DEPLOYMENT_REPLICAS} -gt 1 ]; then
    echo "decrease [deployment]: ${NAMESPACE}/${DEPLOYMENT_NAME}/${DEPLOYMENT_REPLICAS}"
    kubectl -n ${NAMESPACE?} scale deployment ${DEPLOYMENT_NAME?} --replicas 1
  fi
done

echo ""
