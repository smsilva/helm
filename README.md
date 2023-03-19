# Helm Charts

## Create and Install a Helm Chart

### Create an Empty Helm Chart

```bash
# Create charts directory
mkdir charts/

# Create a "app-example" Helm Chart
helm create charts/app-example

# Show app-example structure
find charts/app-example -type f

# Helm Template
helm template charts/app-example
helm template charts/app-example | grep "# Source"

# Remove some files
rm -rf charts/app-example/charts
rm -rf charts/app-example/templates/hpa.yaml
rm -rf charts/app-example/templates/ingress.yaml
rm -rf charts/app-example/templates/NOTES.txt
rm -rf charts/app-example/templates/serviceaccount.yaml
rm -rf charts/app-example/templates/tests

# Show files
find charts/app-example -type f

# Helm Template
helm template charts/app-example | grep "# Source"
helm template charts/app-example

# Remove more files
rm -rf charts/app-example/templates/deployment.yaml
rm -rf charts/app-example/templates/service.yaml
rm -rf charts/app-example/values.yaml

# Show files
find charts/app-example -type f

# Show Template
helm template charts/app-example
```

### Create new Templates

```bash
# Generate a new values.yaml file
cat <<EOF > charts/app-example/values.yaml
config:
  seconds: 10
  timeout: 360
EOF

# Generate a new configmap.yaml file
cat <<EOF > charts/app-example/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config-map
data:
  seconds: {{ .Values.config.seconds | quote }}
  timeout: {{ .Values.config.timeout | quote }}
EOF

# Generate a new NOTES.txt file
cat <<EOF > charts/app-example/templates/NOTES.txt
The config will have {{ .Values.config.seconds | quote }} seconds and a timeout of {{ .Values.config.timeout | quote }} seconds.
EOF

# Show Template
helm template charts/app-example

# Parameters
helm template charts/app-example \
  --set "config.seconds=15" \
  --set "config.timeout=90"
```

### Install

```bash
# Install Helm Chart (Dry Run)
helm install \
  --namespace demo \
  app-example charts/app-example \
  --dry-run

# Install Helm Chart
helm install \
  --namespace demo \
  --create-namespace \
  app-example charts/app-example

# List Helm Releases
helm list -n demo

# Check the ConfigMap
kubectl -n demo get configmap my-config-map -o yaml

# Unistall Helm Release
helm -n demo uninstall app-example

# Install
helm -n demo install app-example charts/app-example 

helm list -n demo # take a look on the last column

# Change Chart Version
grep "^appVersion" charts/app-example/Chart.yaml

sed -i 's/appVersion:.*/appVersion: 1.0.0/g' charts/app-example/Chart.yaml

grep "^appVersion" charts/app-example/Chart.yaml

# Upgrade
helm upgrade \
  --install \
  --namespace demo \
  app-example charts/app-example

helm list --namespace demo #  take a look on the third and last column
```

### Customizing Installation

```bash
# Passing parameters
helm upgrade \
  --namespace demo \
  --install app-example charts/app-example \
  --set "config.seconds=15"

kubectl get configmap my-config-map \
  --namespace demo \
  --output yaml

mkdir -p ${HOME}/trash

cat <<EOF > ${HOME}/trash/values-extra.yaml
config:
  seconds: 15
EOF

cat ${HOME}/trash/values-extra.yaml

helm upgrade \
  --namespace demo \
  --install app-example charts/app-example \
  --values ${HOME}/trash/values-extra.yaml

kubectl get configmap my-config-map \
  --namespace demo \
  --output yaml
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
