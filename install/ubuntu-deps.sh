#!/bin/bash
# Install dependencies on Ubuntu/Debian for dotfiles restore
# Run this first on a fresh Ubuntu machine

set -e

echo "📦 Installing dependencies for Ubuntu..."

# Update package list
sudo apt update

# Install basic tools
sudo apt install -y curl wget git

# Install SOPS (from GitHub releases)
SOPS_VERSION="3.11.0"
echo "Installing SOPS v${SOPS_VERSION}..."
curl -LO "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"
sudo mv "sops-v${SOPS_VERSION}.linux.amd64" /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

# Install age
echo "Installing age..."
sudo apt install -y age || {
    # Fallback: install from GitHub if not in apt
    AGE_VERSION="1.2.0"
    curl -LO "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz"
    tar -xzf "age-v${AGE_VERSION}-linux-amd64.tar.gz"
    sudo mv age/age /usr/local/bin/
    sudo mv age/age-keygen /usr/local/bin/
    rm -rf age "age-v${AGE_VERSION}-linux-amd64.tar.gz"
}

# Verify installations
echo ""
echo "Verifying installations..."
sops --version
age --version

echo ""
echo "✅ Dependencies installed!"
echo ""
echo "Next steps:"
echo "  1. Setup your age key: mkdir -p ~/.config/sops/age"
echo "  2. Paste your key into: ~/.config/sops/age/keys.txt"
echo "  3. Run: ./install/secrets.sh"
