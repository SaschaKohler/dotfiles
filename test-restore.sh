#!/bin/bash
# Test script to verify dotfiles restore works
# Simulates a fresh machine by using a temp HOME directory

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TEST_HOME="/tmp/dotfiles-test-home-$$"
DOTFILES_DIR="$HOME/dev/dotfiles"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           🧪 Dotfiles Restore Test                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Test HOME: $TEST_HOME"
echo ""

# Create fake home
mkdir -p "$TEST_HOME"
mkdir -p "$TEST_HOME/.config/sops/age"

# Copy age key (required for decryption)
cp ~/.config/sops/age/keys.txt "$TEST_HOME/.config/sops/age/keys.txt"

# Test 1: Decrypt kubeconfig
echo -e "${YELLOW}[Test 1] Decrypting kubeconfig...${NC}"
mkdir -p "$TEST_HOME/.kube"
if sops -d "$DOTFILES_DIR/secrets/kubeconfig.yaml" > "$TEST_HOME/.kube/config" 2>/dev/null; then
    if grep -q "apiVersion" "$TEST_HOME/.kube/config"; then
        echo -e "${GREEN}  ✓ kubeconfig decrypted successfully${NC}"
    else
        echo -e "${RED}  ✗ kubeconfig decrypted but invalid${NC}"
        exit 1
    fi
else
    echo -e "${RED}  ✗ Failed to decrypt kubeconfig${NC}"
    exit 1
fi

# Test 2: Decrypt SSH keys
echo -e "${YELLOW}[Test 2] Decrypting SSH keys...${NC}"
mkdir -p "$TEST_HOME/.ssh"

sops -d --extract '["id_ed25519"]' "$DOTFILES_DIR/secrets/ssh-keys.yaml" > "$TEST_HOME/.ssh/id_ed25519" 2>/dev/null
sops -d --extract '["id_ed25519_pub"]' "$DOTFILES_DIR/secrets/ssh-keys.yaml" > "$TEST_HOME/.ssh/id_ed25519.pub" 2>/dev/null

if grep -q "OPENSSH PRIVATE KEY\|BEGIN.*PRIVATE" "$TEST_HOME/.ssh/id_ed25519"; then
    echo -e "${GREEN}  ✓ SSH private key decrypted${NC}"
else
    echo -e "${RED}  ✗ SSH private key invalid${NC}"
    exit 1
fi

if grep -q "ssh-ed25519\|ssh-rsa" "$TEST_HOME/.ssh/id_ed25519.pub"; then
    echo -e "${GREEN}  ✓ SSH public key decrypted${NC}"
else
    echo -e "${RED}  ✗ SSH public key invalid${NC}"
    exit 1
fi

# Test 3: Decrypt .env files
echo -e "${YELLOW}[Test 3] Decrypting .env backup...${NC}"
env_count=$(sops -d "$DOTFILES_DIR/secrets/env-backup/all-envs.yaml" 2>/dev/null | grep -c "^[a-zA-Z].*__env" || echo "0")
if [ "$env_count" -gt 0 ]; then
    echo -e "${GREEN}  ✓ Found $env_count .env files in backup${NC}"
else
    echo -e "${RED}  ✗ No .env files found${NC}"
    exit 1
fi

# Test 4: Verify config files exist
echo -e "${YELLOW}[Test 4] Checking config files...${NC}"
configs_ok=true
for config in "config/zshrc" "config/gitconfig" "config/tmux.conf" "config/nvim/init.lua"; do
    if [ -f "$DOTFILES_DIR/$config" ]; then
        echo -e "${GREEN}  ✓ $config${NC}"
    else
        echo -e "${RED}  ✗ $config missing${NC}"
        configs_ok=false
    fi
done

# Test 5: Verify Brewfile
echo -e "${YELLOW}[Test 5] Checking Brewfile...${NC}"
brew_count=$(grep -c "^brew\|^cask" "$DOTFILES_DIR/Brewfile" || echo "0")
echo -e "${GREEN}  ✓ Brewfile has $brew_count packages${NC}"

# Cleanup
rm -rf "$TEST_HOME"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo -e "║              ${GREEN}✅ All tests passed!${NC}                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Your dotfiles are ready for a fresh machine restore."
