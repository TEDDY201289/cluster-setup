🔧 Step-by-Step Guide
📦 1. Install MetalLB
Step 1: Enable strict ARP

bash
Copy
Edit
kubectl get configmap kube-proxy -n kube-system -o yaml > kube-proxy.yaml
Edit the config:

yaml
Copy
Edit
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
featureGates:
  SupportIPVSProxyMode: true
strictARP: true
Then apply:

bash
Copy
Edit
kubectl apply -f kube-proxy.yaml
Step 2: Install MetalLB

bash
Copy
Edit
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
Step 3: Configure MetalLB IP Pool

yaml
Copy
Edit
# metallb-config.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: my-ip-pool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.1.240-192.168.1.250  # Customize for your local network

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2adv
  namespace: metallb-system
bash
Copy
Edit
kubectl apply -f metallb-config.yaml
🌐 2. Install NGINX Ingress Controller with MetalLB
Step 1: Create namespace

bash
Copy
Edit
kubectl create namespace ingress-nginx
Step 2: Apply ingress controller

bash
Copy
Edit
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/baremetal/deploy.yaml
Step 3: Patch NGINX service to use MetalLB

bash
Copy
Edit
kubectl patch svc ingress-nginx-controller -n ingress-nginx \
  -p '{"spec": {"type": "LoadBalancer"}}'
➡️ You should now see an external IP from MetalLB assigned:

bash
Copy
Edit
kubectl get svc -n ingress-nginx
📊 3. Install SUSE Observability Stack
You can use Rancher’s Prometheus Stack (or SUSE Prometheus Helm charts):

bash
Copy
Edit
helm repo add rancher-charts https://charts.rancher.io
helm repo update

helm install suse-observability rancher-charts/rancher-monitoring \
  -n cattle-monitoring-system --create-namespace
To expose Grafana/Prometheus publicly, use an Ingress like:

yaml
Copy
Edit
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: cattle-monitoring-system
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: grafana.mydomain.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: rancher-monitoring-grafana
            port:
              number: 80
Add that domain (e.g. grafana.mydomain.local) to your local DNS or /etc/hosts.