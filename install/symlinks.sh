#!/bin/bash
# Symlink dotfiles to home directory

DOTFILES_DIR="$HOME/dev/dotfiles"
CONFIG_DIR="$DOTFILES_DIR/config"

# Helper function
link_file() {
    local src=$1
    local dest=$2
    
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -f "$dest" ] || [ -d "$dest" ]; then
        echo "  Backing up existing $dest to ${dest}.backup"
        mv "$dest" "${dest}.backup"
    fi
    
    ln -sf "$src" "$dest"
    echo "  Linked: $dest -> $src"
}

echo "Creating symlinks..."

# Create .config if not exists
mkdir -p "$HOME/.config"

# Zsh
link_file "$CONFIG_DIR/zshrc" "$HOME/.zshrc"

# Git
link_file "$CONFIG_DIR/gitconfig" "$HOME/.gitconfig"
link_file "$CONFIG_DIR/gitignore_global" "$HOME/.gitignore"

# Tmux
link_file "$CONFIG_DIR/tmux.conf" "$HOME/.tmux.conf"
link_file "$CONFIG_DIR/tmux" "$HOME/.config/tmux"

# Tmuxinator
link_file "$CONFIG_DIR/tmuxinator" "$HOME/.config/tmuxinator"

# Neovim
link_file "$CONFIG_DIR/nvim" "$HOME/.config/nvim"

echo "Symlinks created ✓"
