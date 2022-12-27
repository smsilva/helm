#!/bin/sh

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

NODE_NAME="$1"

curl \
  --silent \
  --cacert ${CACERT?} \
  --header "Authorization: Bearer ${TOKEN?}" \
  --request GET ${APISERVER?}/api/v1/nodes/${NODE_NAME?}/proxy/metrics
