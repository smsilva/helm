#!/bin/sh

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

while true; do
  MESSAGE=$(printf '[%s] %s ' "$(date +"%Y-%m-%d %H:%M:%S %:z")" "exec curl")

  echo "${MESSAGE}"

  curl \
    --silent \
    --cacert ${CACERT} \
    --header "Authorization: Bearer ${TOKEN}" \
    --request GET ${APISERVER}/metrics | grep \
      -E "^apiserver_flowcontrol_current_inqueue_requests|^etcd_db_total_size_in_bytes|^process_resident_memory_bytes"

  echo ""

  sleep 10
done
