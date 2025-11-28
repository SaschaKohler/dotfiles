#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_DIR="$HOME/dev/dotfiles"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🚀 Stateless Workstation Bootstrap - Sascha Kohler     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ===========================================
# STEP 1: Homebrew
# ===========================================
echo -e "${YELLOW}[1/5] Checking Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${GREEN}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}Homebrew already installed ✓${NC}"
fi

# ===========================================
# STEP 2: Install packages from Brewfile
# ===========================================
echo ""
echo -e "${YELLOW}[2/5] Installing packages from Brewfile...${NC}"
brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock

# ===========================================
# STEP 3: Oh-My-Zsh
# ===========================================
echo ""
echo -e "${YELLOW}[3/5] Setting up Oh-My-Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}Installing Oh-My-Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Pure prompt
if [ ! -d "$HOME/.zsh/pure" ]; then
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi
echo -e "${GREEN}Oh-My-Zsh ready ✓${NC}"

# ===========================================
# STEP 4: Symlinks
# ===========================================
echo ""
echo -e "${YELLOW}[4/5] Creating symlinks...${NC}"
source "$DOTFILES_DIR/install/symlinks.sh"

# ===========================================
# STEP 5: Tmux Plugin Manager
# ===========================================
echo ""
echo -e "${YELLOW}[5/5] Setting up Tmux...${NC}"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
echo -e "${GREEN}Tmux Plugin Manager ready ✓${NC}"

# ===========================================
# FZF Key Bindings
# ===========================================
if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# ===========================================
# DONE
# ===========================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    ✅ Bootstrap Complete!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Open tmux and press: prefix + I (to install plugins)"
echo "  3. Open nvim - LazyVim will auto-install plugins"
echo "  4. Setup kubectl config for your cluster"
echo ""
echo -e "${YELLOW}Time to restore:${NC} ~10-15 minutes ⏱️"
