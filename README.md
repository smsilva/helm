# Helm Charts

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
