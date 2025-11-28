#!/bin/bash
# Full Ubuntu/Linux workstation setup
# Installs: neovim, kubectl, k9s, tmux, zsh, fzf, ripgrep, etc.

set -e

echo "🚀 Setting up Linux workstation..."

# Use sudo if available and not root
if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then
    SUDO="sudo"
else
    SUDO=""
fi

# Update and install base packages
$SUDO apt update
$SUDO apt install -y \
    curl wget git \
    zsh tmux \
    fzf ripgrep fd-find bat \
    unzip tar gzip \
    build-essential

# ============================================
# Neovim (latest from GitHub - LazyVim needs >= 0.11.2)
# ============================================
echo "📝 Installing Neovim..."
NVIM_VERSION="0.11.2"
curl -LO "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
tar -xzf nvim-linux-x86_64.tar.gz
$SUDO mv nvim-linux-x86_64 /opt/nvim
$SUDO ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
echo "  ✓ Neovim $(nvim --version | head -1)"

# ============================================
# kubectl
# ============================================
echo "☸️  Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$SUDO install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
echo "  ✓ kubectl $(kubectl version --client --short 2>/dev/null || kubectl version --client | head -1)"

# ============================================
# k9s
# ============================================
echo "🐶 Installing k9s..."
K9S_VERSION="0.32.5"
curl -LO "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -xzf k9s_Linux_amd64.tar.gz k9s
$SUDO mv k9s /usr/local/bin/
rm k9s_Linux_amd64.tar.gz
echo "  ✓ k9s $(k9s version | head -1)"

# ============================================
# lazygit
# ============================================
echo "🔀 Installing lazygit..."
LAZYGIT_VERSION="0.44.1"
curl -LO "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xzf "lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" lazygit
$SUDO mv lazygit /usr/local/bin/
rm "lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
echo "  ✓ lazygit"

# ============================================
# Node.js (for LSPs in Neovim)
# ============================================
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | $SUDO bash -
$SUDO apt install -y nodejs
echo "  ✓ Node $(node --version)"

# ============================================
# tmuxinator (Ruby gem)
# ============================================
echo "📋 Installing tmuxinator..."
$SUDO apt install -y ruby
$SUDO gem install tmuxinator
echo "  ✓ tmuxinator $(tmuxinator version)"

# ============================================
# Symlinks for fd and bat (Ubuntu names them differently)
# ============================================
$SUDO ln -sf /usr/bin/fdfind /usr/local/bin/fd 2>/dev/null || true
$SUDO ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true

# ============================================
# Setup configs from dotfiles
# ============================================
DOTFILES_DIR="/dotfiles"
if [ -d "$DOTFILES_DIR/config" ]; then
    echo "🔗 Linking configs..."
    
    # Neovim
    mkdir -p ~/.config
    ln -sf "$DOTFILES_DIR/config/nvim" ~/.config/nvim
    echo "  ✓ nvim config"
    
    # Tmux
    ln -sf "$DOTFILES_DIR/config/tmux.conf" ~/.tmux.conf
    echo "  ✓ tmux config"
    
    # Tmuxinator
    if [ -d "$DOTFILES_DIR/config/tmuxinator" ]; then
        ln -sf "$DOTFILES_DIR/config/tmuxinator" ~/.config/tmuxinator
        echo "  ✓ tmuxinator config"
    fi
    
    # Git
    ln -sf "$DOTFILES_DIR/config/gitconfig" ~/.gitconfig
    echo "  ✓ git config"
fi

# ============================================
# Restore secrets if age key present
# ============================================
if [ -f ~/.config/sops/age/keys.txt ]; then
    echo "🔐 Restoring secrets..."
    
    # kubeconfig
    if [ -f "$DOTFILES_DIR/secrets/kubeconfig.yaml" ]; then
        mkdir -p ~/.kube
        sops -d "$DOTFILES_DIR/secrets/kubeconfig.yaml" > ~/.kube/config
        chmod 600 ~/.kube/config
        echo "  ✓ kubeconfig"
    fi
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              ✅ Linux workstation ready!                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Installed:"
echo "  - neovim 0.11.2 (LazyVim config linked)"
echo "  - kubectl + k9s"
echo "  - tmux + tmuxinator"
echo "  - lazygit, fzf, ripgrep"
echo ""
echo "Try:"
echo "  nvim              # LazyVim"
echo "  kubectl get nodes # K8s cluster"
echo "  k9s               # K8s TUI"
echo "  tmux              # Terminal multiplexer"
