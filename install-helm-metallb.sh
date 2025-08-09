#!/bin/bash
set -euo pipefail

echo "[1/5] Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "[2/5] Adding MetalLB Helm repo..."
helm repo add metallb https://metallb.github.io/metallb
helm repo update

echo "[3/5] Installing MetalLB in metallb-system namespace..."
kubectl create namespace metallb-system || true
helm install metallb metallb/metallb -n metallb-system

echo "[4/5] Configuring MetalLB address pool (192.168.90.1-192.168.90.30)..."

cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.90.1-192.168.90.30
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2adv
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

echo "[5/5] ✅ MetalLB and Helm installation complete!"
kubectl get pods -n metallb-system
