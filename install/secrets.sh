#!/bin/bash
# Restore secrets from encrypted files

DOTFILES_DIR="$HOME/dev/dotfiles"
SECRETS_DIR="$DOTFILES_DIR/secrets"

echo "🔐 Restoring secrets..."

# Check if age key exists
if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
    echo "❌ Age key not found at ~/.config/sops/age/keys.txt"
    echo "   Please restore your age key first!"
    exit 1
fi

# Kubeconfig
if [ -f "$SECRETS_DIR/kubeconfig.yaml" ]; then
    mkdir -p ~/.kube
    sops -d "$SECRETS_DIR/kubeconfig.yaml" > ~/.kube/config
    chmod 600 ~/.kube/config
    echo "  ✓ kubeconfig restored"
fi

echo ""
echo "✅ Secrets restored!"
