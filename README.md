## Helm Test

```bash
helm repo add terraform-controller https://smsilva.github.io/helm/

helm repo list

helm repo update

helm install terraform-controller terraform-controller/terraform-controller

kubectl wait \
  deployment terraform-controller \
  --for=condition=Available \
  --timeout=360s

kubectl logs -f -l app=terraform-controller

cat <<EOF | kubectl apply -f -
apiVersion: terraform.silvios.me/v1alpha1
kind: StackInstance
metadata:
  name: generic-bucket-1
spec:
  stack:
    provider: google
    image: silviosilva/google-bucket
    version: 0.3.1
    registry: docker.io
  vars:
    name: {{ $instance.name }}
    location: {{ $instance.location }}
  outputs:
    - bucket_id
EOF

kubectl get StackInstance
```
