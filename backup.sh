#!/bin/bash
# Backup current dotfiles to the repo

DOTFILES_DIR="$HOME/dev/dotfiles"
CONFIG_DIR="$DOTFILES_DIR/config"

echo "📦 Backing up dotfiles..."

# Zsh
cp ~/.zshrc "$CONFIG_DIR/zshrc"
echo "  ✓ zshrc"

# Git
cp ~/.gitconfig "$CONFIG_DIR/gitconfig"
[ -f ~/.gitignore ] && cp ~/.gitignore "$CONFIG_DIR/gitignore_global"
echo "  ✓ gitconfig"

# Tmux
cp ~/.tmux.conf "$CONFIG_DIR/tmux.conf"
cp -r ~/.config/tmux/* "$CONFIG_DIR/tmux/"
echo "  ✓ tmux"

# Tmuxinator
cp -r ~/.config/tmuxinator/* "$CONFIG_DIR/tmuxinator/"
echo "  ✓ tmuxinator"

# Neovim (nur lua und init.lua, nicht lazy-lock)
cp ~/.config/nvim/init.lua "$CONFIG_DIR/nvim/"
cp -r ~/.config/nvim/lua/* "$CONFIG_DIR/nvim/lua/"
echo "  ✓ nvim"

# Update Brewfile
brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force
echo "  ✓ Brewfile"

echo ""
echo "✅ Backup complete!"
echo ""
echo "Don't forget to commit and push:"
echo "  cd $DOTFILES_DIR && git add -A && git commit -m 'Update dotfiles' && git push"
