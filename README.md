# Sascha's Dotfiles - Stateless Workstation

> "Treat your laptop like cattle, not pets" - DevOps Wisdom

Diese Dotfiles ermöglichen es, eine neue macOS Workstation in **unter 15 Minuten** vollständig einzurichten.

## Quick Start (Neue Maschine)

```bash
# 1. Xcode Command Line Tools installieren
xcode-select --install

# 2. Dotfiles klonen
git clone https://github.com/SaschaKohler/dotfiles.git ~/dev/dotfiles

# 3. Bootstrap ausführen
cd ~/dev/dotfiles && ./bootstrap.sh
```

## Was wird installiert?

### Tools (via Homebrew)
- **Editor**: neovim (LazyVim), vim
- **Terminal**: tmux, tmuxinator, fish, zsh
- **Git**: git, lazygit, hub, tig
- **Kubernetes**: kubectl, k9s, helm
- **Dev Tools**: node, python, php, composer
- **CLI Utils**: fzf, ripgrep, fd, eza, bat, zoxide

### Konfigurationen
- `~/.config/nvim/` - LazyVim Setup
- `~/.tmux.conf` + `~/.config/tmux/` - Tmux Config
- `~/.config/tmuxinator/` - Projekt-Sessions
- `~/.zshrc` - Zsh mit oh-my-zsh
- `~/.gitconfig` - Git Aliases & Config

## Struktur

```
dotfiles/
├── bootstrap.sh          # Haupt-Setup-Script
├── Brewfile              # Alle Homebrew Packages
├── install/              # Installations-Scripts
│   ├── brew.sh
│   ├── symlinks.sh
│   └── macos.sh
├── config/               # Dotfiles zum Symlinken
│   ├── nvim/
│   ├── tmux/
│   ├── tmuxinator/
│   ├── zshrc
│   ├── gitconfig
│   └── tmux.conf
└── scripts/              # Utility Scripts
```

## Backup erstellen

```bash
./backup.sh
```

## Kubernetes Cluster Zugang

Nach dem Bootstrap muss die kubeconfig manuell eingerichtet werden:
```bash
# Kubeconfig von sicherem Ort kopieren oder neu generieren
mkdir -p ~/.kube
# scp user@server:~/.kube/config ~/.kube/config
```

## Syncthing (Optional)

Für Sync von `Active_Projects` zwischen Maschinen:
```bash
brew install syncthing
brew services start syncthing
# Dann http://localhost:8384 öffnen
```
