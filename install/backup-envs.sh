#!/bin/bash
# Backup all .env files to encrypted YAML

DOTFILES_DIR="$HOME/dev/dotfiles"
SECRETS_DIR="$DOTFILES_DIR/secrets"
PROJECTS_DIR="$HOME/Documents/01_Development/Active_Projects"
ENV_BACKUP="$SECRETS_DIR/env-backup/all-envs.yaml"

echo "📦 Backing up .env files..."

mkdir -p "$(dirname "$ENV_BACKUP")"

# Create YAML header
cat > "$ENV_BACKUP" << EOF
# All .env files from Active_Projects
# Encrypted with SOPS - safe to commit
# Last updated: $(date +%Y-%m-%d)
EOF

# Find and add all .env files
find "$PROJECTS_DIR" -maxdepth 4 -name ".env*" -type f ! -name "*.example" ! -path "*/node_modules/*" 2>/dev/null | while read envfile; do
    relpath="${envfile#$PROJECTS_DIR/}"
    key=$(echo "$relpath" | tr '/.' '__')
    echo "" >> "$ENV_BACKUP"
    echo "# $relpath" >> "$ENV_BACKUP"
    echo "${key}: |" >> "$ENV_BACKUP"
    sed 's/^/  /' "$envfile" >> "$ENV_BACKUP"
    echo "  ✓ $relpath"
done

# Encrypt
echo ""
echo "🔐 Encrypting..."
sops --encrypt --in-place "$ENV_BACKUP"

echo ""
echo "✅ .env backup complete!"
echo "   Don't forget to commit: git add -A && git commit -m 'Update env backup'"
