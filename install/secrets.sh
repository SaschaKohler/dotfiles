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

# SSH Keys
if [ -f "$SECRETS_DIR/ssh-keys.yaml" ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    # Extract each key from YAML
    sops -d --extract '["id_ed25519"]' "$SECRETS_DIR/ssh-keys.yaml" > ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    
    sops -d --extract '["id_ed25519_pub"]' "$SECRETS_DIR/ssh-keys.yaml" > ~/.ssh/id_ed25519.pub
    chmod 644 ~/.ssh/id_ed25519.pub
    
    sops -d --extract '["id_rsa"]' "$SECRETS_DIR/ssh-keys.yaml" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    
    sops -d --extract '["id_rsa_pub"]' "$SECRETS_DIR/ssh-keys.yaml" > ~/.ssh/id_rsa.pub
    chmod 644 ~/.ssh/id_rsa.pub
    
    sops -d --extract '["ssh_config"]' "$SECRETS_DIR/ssh-keys.yaml" > ~/.ssh/config
    chmod 600 ~/.ssh/config
    
    echo "  ✓ SSH keys restored"
fi

echo ""
echo "✅ Secrets restored!"
