#!/bin/bash
# Install dependencies on Ubuntu/Debian for dotfiles restore
# Run this first on a fresh Ubuntu machine

set -e

echo "📦 Installing dependencies for Ubuntu..."

# Use sudo if available and not root, otherwise run directly
if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then
    SUDO="sudo"
else
    SUDO=""
fi

# Update package list
$SUDO apt update

# Install basic tools
$SUDO apt install -y curl wget git

# Install SOPS (from GitHub releases - not in apt)
SOPS_VERSION="3.11.0"
echo "Installing SOPS v${SOPS_VERSION}..."
curl -LO "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"
$SUDO mv "sops-v${SOPS_VERSION}.linux.amd64" /usr/local/bin/sops
$SUDO chmod +x /usr/local/bin/sops

# Install age (not in Ubuntu 22.04 apt, download from GitHub)
AGE_VERSION="1.2.0"
echo "Installing age v${AGE_VERSION}..."
curl -LO "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz"
tar -xzf "age-v${AGE_VERSION}-linux-amd64.tar.gz"
$SUDO mv age/age /usr/local/bin/
$SUDO mv age/age-keygen /usr/local/bin/
rm -rf age "age-v${AGE_VERSION}-linux-amd64.tar.gz"

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
