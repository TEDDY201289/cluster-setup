#!/bin/bash

echo "[*] Fixing kubeconfig access for vagrant user..."

KUBECONFIG_SOURCE="/etc/kubernetes/admin.conf"
KUBECONFIG_DEST="/home/vagrant/kubeconfig.vagrant"
BASHRC_FILE="/home/vagrant/.bashrc"

# Copy kubeconfig safely to a non-synced, user-owned location
sudo cp -f "$KUBECONFIG_SOURCE" "$KUBECONFIG_DEST"
sudo chown vagrant:vagrant "$KUBECONFIG_DEST"
sudo chmod 644 "$KUBECONFIG_DEST"

# Add to .bashrc if not already present
if ! grep -q "export KUBECONFIG=$KUBECONFIG_DEST" "$BASHRC_FILE"; then
  echo "export KUBECONFIG=$KUBECONFIG_DEST" | sudo tee -a "$BASHRC_FILE"
  echo "[+] Added export to .bashrc"
fi

echo "[✓] kubeconfig is ready. Try: kubectl get nodes"
