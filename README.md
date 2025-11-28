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

## Secrets Management (SOPS + age)

Sensible Daten (kubeconfig, SSH keys, .env files) sind mit SOPS verschlüsselt.

### Voraussetzung: Age Key

Der private Schlüssel muss vorhanden sein in `~/.config/sops/age/keys.txt`.
Diesen Key aus dem Password Manager holen!

```bash
mkdir -p ~/.config/sops/age
# Key aus Password Manager in keys.txt einfügen
```

### Secrets manuell wiederherstellen

```bash
# Kubeconfig
sops -d secrets/kubeconfig.yaml > ~/.kube/config

# SSH Keys
./install/secrets.sh

# .env Dateien
./install/restore-envs.sh
```

### Test ob alles funktioniert

```bash
./test-restore.sh
```

## Ubuntu/Linux Setup

Für eine vollständige Linux-Workstation (oder Docker-Container):

```bash
./install/ubuntu-deps.sh    # SOPS + age
./install/ubuntu-full.sh    # Neovim, kubectl, k9s, tmux, etc.
```

📖 **Ausführliche Anleitung:** [docs/LINUX_WORKSTATION.md](docs/LINUX_WORKSTATION.md)

### Docker Quick Start

```bash
docker run -it --rm \
  -v ~/dev/dotfiles:/dotfiles \
  -v ~/.config/sops/age:/root/.config/sops/age \
  -v ~/Documents/01_Development/Active_Projects:/projects \
  -p 3000:3000 -p 5173:5173 -p 8080:8080 \
  ubuntu:22.04 bash

# Im Container:
cd /dotfiles && ./install/ubuntu-deps.sh && ./install/ubuntu-full.sh
```

## Syncthing (Optional)

Für Sync von `Active_Projects` zwischen Maschinen:
```bash
brew install syncthing
brew services start syncthing
# Dann http://localhost:8384 öffnen
```

Syncthing läuft auch auf dem K8s Cluster: https://sync.sascha-kohler.at
