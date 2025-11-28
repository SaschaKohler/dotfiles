# Encrypted Secrets

Diese Dateien sind mit SOPS + age verschlüsselt und können sicher in Git committed werden.

## Voraussetzungen

```bash
brew install sops age
```

## Schlüssel

Der private Schlüssel liegt in `~/.config/sops/age/keys.txt` und muss auf jeder Maschine vorhanden sein.

**WICHTIG:** Sichere diesen Schlüssel separat (z.B. Password Manager)!

## Verwendung

### Secret entschlüsseln (anzeigen)
```bash
sops -d secrets/kubeconfig.yaml
```

### Secret entschlüsseln und speichern
```bash
sops -d secrets/kubeconfig.yaml > ~/.kube/config
chmod 600 ~/.kube/config
```

### Secret bearbeiten
```bash
sops secrets/kubeconfig.yaml
```

### Neues Secret verschlüsseln
```bash
sops -e plaintext.yaml > secrets/encrypted.yaml
```

## Enthaltene Secrets

- `kubeconfig.yaml` - Kubernetes Cluster Zugang
