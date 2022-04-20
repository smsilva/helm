# Helm Charts

## Install kind and Create a Local Cluster

[Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start)

## Setting up this repo

```bash
git clone https://github.com/smsilva/helm.git
cd helm
```

## Create and Install a Helm Chart

```bash
# Create a "mychart" Helm Chart
helm create charts/mychart

# remove files
rm -rf charts/mychart/charts
rm -rf charts/mychart/templates/deployment.yaml
rm -rf charts/mychart/templates/hpa.yaml
rm -rf charts/mychart/templates/ingress.yaml
rm -rf charts/mychart/templates/NOTES.txt
rm -rf charts/mychart/templates/service.yaml
rm -rf charts/mychart/templates/serviceaccount.yaml
rm -rf charts/mychart/templates/tests
rm -rf charts/mychart/values.yaml

# Show mychart structure
find charts/mychart -type f

# Show Template
helm template mychart-example charts/mychart

# Generate a new values.yaml file
cat <<EOF > charts/mychart/values.yaml
config:
  replicas: 3
  timeout: 360
EOF

# Generate a new configmap.yaml file
cat <<EOF > charts/mychart/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config-map
data:
  replicas: {{ .Values.config.replicas | quote }}
  timeout: {{ .Values.config.timeout | quote }}
EOF

# Generate a new NOTES.txt file
cat <<EOF > charts/mychart/templates/NOTES.txt
The config will have {{ .Values.config.replicas | quote }} replicas and a timeout of {{ .Values.config.timeout | quote }} seconds.
EOF

# Show Template
helm template mychart-example charts/mychart

# Install Helm Chart
helm install mychart-example charts/mychart

# List Helm Releases
helm list

# Check the ConfigMap
kubectl get configmap my-config-map -o yaml

# Unistall Helm Release
helm uninstall mychart-example

# Install
helm install mychart-example charts/mychart 
helm list # take a look on the last column

# Change Chart Version
grep "^appVersion" charts/mychart/Chart.yaml

sed -i 's/appVersion:.*/appVersion: 1.0.0/g' charts/mychart/Chart.yaml

grep "^appVersion" charts/mychart/Chart.yaml

# Upgrade
helm upgrade --install mychart-example charts/mychart
helm list #  take a look on the third and last column

# Passing parameters
helm upgrade \
  --install mychart-example charts/mychart \
  --set "config.replicas=10"

kubectl get configmap my-config-map -o yaml

mkdir -p ${HOME}/trash

cat <<EOF > ${HOME}/trash/values-extra.yaml
config:
  replicas: 15
EOF

cat ${HOME}/trash/values-extra.yaml

helm upgrade \
  --install mychart-example charts/mychart \
  --values ${HOME}/trash/values-extra.yaml

kubectl get configmap my-config-map -o yaml
```

## Packaging

### Package Helm Chart

```bash
helm package \
  charts/httpbin \
  --destination releases/
```

### Generate Helm Index File

```bash
helm repo index \
  releases/ \
  --url https://raw.githubusercontent.com/smsilva/helm/main/releases
```

## Usage Example

```bash
helm repo add \
  smsilva https://raw.githubusercontent.com/smsilva/helm/main/releases

helm repo update smsilva
helm search repo smsilva

helm upgrade \
  --install \
  --namespace httpbin \
  --create-namespace \
  --version "0.1.0" \
  httpbin smsilva/httpbin \
  --wait && \
kubectl \
  --namespace httpbin \
  get deployments,pods,services
```

## Cleanup

```bash
helm uninstall httpbin \
  --namespace httpbin \
  --wait && \
kubectl delete namespace httpbin && \
kubectl get namespaces
```
