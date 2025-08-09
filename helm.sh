helm search repo list
helm pull xxxx --version 9.2.2 --untar
watch helm list -A
helm install releasename
helm install usd-app currency-app-helmchart/
helm install aud-app currency-app-helmchart/ --values aud-helm-values.yaml
kubectl get pod usd-currency-app -o yaml