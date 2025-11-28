#!/bin/bash
# Restore all .env files from encrypted backup

DOTFILES_DIR="$HOME/dev/dotfiles"
SECRETS_DIR="$DOTFILES_DIR/secrets"
PROJECTS_DIR="$HOME/Documents/01_Development/Active_Projects"
ENV_BACKUP="$SECRETS_DIR/env-backup/all-envs.yaml"

echo "🔐 Restoring .env files..."

# Check if age key exists
if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
    echo "❌ Age key not found at ~/.config/sops/age/keys.txt"
    exit 1
fi

if [ ! -f "$ENV_BACKUP" ]; then
    echo "❌ Env backup not found at $ENV_BACKUP"
    exit 1
fi

# Get all keys from the YAML (excluding sops metadata)
keys=$(sops -d "$ENV_BACKUP" | grep -E "^[a-zA-Z0-9_-]+__env" | sed 's/:.*//')

for key in $keys; do
    # Convert key back to path: vitanova__env_local -> vitanova/.env.local
    path=$(echo "$key" | sed 's/__env_local$/.env.local/' | sed 's/__env_production$/.env.production/' | sed 's/__env_test$/.env.test/' | sed 's/__env$/.env/' | tr '_' '/')
    
    # Fix double slashes and path issues
    path=$(echo "$path" | sed 's|//|/|g')
    
    fullpath="$PROJECTS_DIR/$path"
    dir=$(dirname "$fullpath")
    
    # Create directory if needed
    mkdir -p "$dir"
    
    # Extract and save
    sops -d --extract "[\"$key\"]" "$ENV_BACKUP" > "$fullpath" 2>/dev/null
    
    if [ -s "$fullpath" ]; then
        echo "  ✓ $path"
    fi
done

echo ""
echo "✅ .env files restored!"
