# Linux Workstation Setup

Diese Anleitung beschreibt, wie du eine vollständige Entwicklungsumgebung auf Linux (oder in Docker) einrichtest.

## Voraussetzungen

Du brauchst nur **eine Sache**: Den **Age Private Key** aus deinem Password Manager.

Alles andere (SSH Keys, Kubeconfig, .env Dateien) wird daraus wiederhergestellt.

---

## Option 1: Docker Container (zum Testen)

### Auf deinem Mac (mit lokalen Projekten)

```bash
docker run -it --rm \
  -v ~/dev/dotfiles:/dotfiles \
  -v ~/.config/sops/age:/root/.config/sops/age \
  -v ~/Documents/01_Development/Active_Projects:/projects \
  -p 3000:3000 \
  -p 5173:5173 \
  -p 8080:8080 \
  ubuntu:22.04 bash
```

### Im Container: Setup

```bash
cd /dotfiles
./install/ubuntu-deps.sh    # SOPS + age installieren
./install/ubuntu-full.sh    # Neovim, kubectl, k9s, tmux, etc.
```

### Arbeiten

```bash
cd /projects/breading
npm install
npm run dev -- --host 0.0.0.0
```

Browser öffnen: `http://localhost:5173`

---

## Option 2: Neuer Linux Rechner / VM

### 1. Dotfiles klonen

```bash
git clone https://github.com/SaschaKohler/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
```

### 2. Age Key einrichten

```bash
mkdir -p ~/.config/sops/age
nano ~/.config/sops/age/keys.txt
```

Inhalt (aus Password Manager):
```
# created: 2025-11-28T...
# public key: age1ynrmvqhkwde3k6x06307elr3xvu2fn5mh2xuzlrp7cxj5lnkms6qtmd626
AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### 3. Setup ausführen

```bash
./install/ubuntu-deps.sh    # SOPS + age
./install/ubuntu-full.sh    # Alle Tools
```

### 4. Projekte holen

**Via Git:**
```bash
mkdir -p ~/projects
cd ~/projects
git clone git@github.com:SaschaKohler/breading.git
```

**Via Syncthing:**
```bash
apt install -y syncthing
syncthing &
# Browser: http://localhost:8384
# Mit sync.sascha-kohler.at verbinden
```

### 5. .env Dateien wiederherstellen

```bash
cd ~/dev/dotfiles
./install/restore-envs.sh
```

---

## Was wird installiert?

| Tool | Version | Zweck |
|------|---------|-------|
| **neovim** | 0.11.2 | Editor mit LazyVim |
| **kubectl** | latest | Kubernetes CLI |
| **k9s** | 0.32.5 | Kubernetes TUI |
| **lazygit** | 0.44.1 | Git TUI |
| **tmux** | - | Terminal Multiplexer |
| **tmuxinator** | - | Tmux Session Manager |
| **fzf** | - | Fuzzy Finder |
| **ripgrep** | - | Schnelle Suche |
| **fd** | - | Schnelles find |
| **bat** | - | cat mit Syntax Highlighting |
| **Node.js** | 20.x | JavaScript Runtime |

---

## Port Mapping (Docker)

Wenn du im Container einen Dev Server startest, musst du:

1. **Ports beim Start mappen:**
```bash
docker run -p 5173:5173 ...
```

2. **Server auf 0.0.0.0 binden:**
```bash
# Vite
npm run dev -- --host 0.0.0.0

# Next.js  
npm run dev -- -H 0.0.0.0
```

3. **Im Browser öffnen:**
```
http://localhost:5173
```

---

## Secrets Übersicht

| Secret | Datei | Wiederherstellung |
|--------|-------|-------------------|
| Age Key | `~/.config/sops/age/keys.txt` | Password Manager (manuell) |
| Kubeconfig | `secrets/kubeconfig.yaml` | Automatisch via `ubuntu-full.sh` |
| SSH Keys | `secrets/ssh-keys.yaml` | `./install/secrets.sh` |
| .env Dateien | `secrets/env-backup/all-envs.yaml` | `./install/restore-envs.sh` |

---

## Schnelltest

Nach dem Setup kannst du testen:

```bash
# Neovim mit LazyVim
nvim

# Kubernetes Cluster
kubectl get nodes
k9s

# Git
lazygit

# Tmux
tmux
```

---

## Troubleshooting

### "Permission denied" bei SSH
```bash
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 700 ~/.ssh
```

### Neovim Plugins laden nicht
```bash
nvim --headless "+Lazy! sync" +qa
```

### kubectl: connection refused
```bash
# Kubeconfig prüfen
cat ~/.kube/config | head -5

# Neu entschlüsseln
sops -d /dotfiles/secrets/kubeconfig.yaml > ~/.kube/config
```
