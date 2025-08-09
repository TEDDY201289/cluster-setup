#!/bin/bash

set -euo pipefail

ARCH=$(dpkg --print-architecture)

echo "[1/10] Updating package index..."
sudo apt-get update -y

echo "[2/10] Installing HTTPS transport packages..."
sudo apt-get install -y \
  ca-certificates \
  curl \
  software-properties-common \
  gnupg \
  lsb-release

echo "[3/10] Loading required kernel modules..."
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

echo "[4/10] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "[5/10] Configuring sysctl parameters..."
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

echo "[6/10] Installing containerd..."

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repo (arch-aware)
echo \
  "deb [arch=${ARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

# Install containerd (latest version compatible with your arch)
sudo apt-get install -y containerd.io

# Configure containerd with systemd cgroup driver
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

echo "[7/10] Installing Kubernetes components..."

# Add Kubernetes signing key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

# Install Kubernetes tools
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "[8/10] Initializing Kubernetes control-plane..."
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

echo "[9/10] Configuring kubeconfig for current user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[10/10] Installing Calico CNI..."
sudo chmod 644 /etc/kubernetes/admin.conf

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "Setup complete. Verifying cluster..."
kubectl get nodes
kubectl get pods -n kube-system
kubectl get --raw='/readyz?verbose' || true

echo "✅ Kubernetes control-plane is ready!"

#calico should be installed
#kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml


echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
source ~/.bashrc

# if option 2
#export KUBECONFIG=/etc/kubernetes/admin.conf
#export KUBECONFIG=/etc/kubernetes/admin.conf
# kubectl get nodes
#kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true #if coreDNS is not running use this

#kubeadm token create --print-join-command

#Tigera and Calico
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/operator-crds.yaml
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/tigera-operator.yaml
# kubectl create -f custom-resources.yaml



