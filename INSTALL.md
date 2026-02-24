# Installation Guide

## Requirements

- Go 1.21 or later
- Git

## Install via Go

```bash
go install github.com/onedns/onedns@latest
```

The binary will be installed to `$GOPATH/bin/onedns`.

## Build from Source

### Clone Repository

```bash
git clone https://github.com/onedns/onedns.git
cd onedns
```

### Build

```bash
go build -o onedns ./cmd/onedns
```

### Install System-wide

```bash
sudo mv onedns /usr/local/bin/
```

## Verify Installation

```bash
onedns --version
onedns query example.com
```

## Configuration

### Create Config Directory

```bash
mkdir -p ~/.config/onedns
```

### Create Configuration File

```bash
cat > ~/.config/onedns/config.json << 'EOF'
{
  "version": "1.0",
  "defaults": {
    "output_level": "long",
    "color": true,
    "timeout": "10s",
    "retries": 3
  },
  "resolvers": {
    "default": ["8.8.8.8", "1.1.1.1"],
    "dnssec_validation": ["9.9.9.9"]
  }
}
EOF
```

## Optional: dnsscience.io Setup

To enable dnsscience.io integration:

1. Obtain API key from https://dnsscience.io
2. Save the key file:
   ```bash
   mv ~/Downloads/dnsscience-api-key.json ~/.config/onedns/
   ```
3. Configure the key:
   ```bash
   onedns science key set ~/.config/onedns/dnsscience-api-key.json
   ```

## Optional: DDI Appliance Setup

### Infoblox

```bash
onedns appliance set infoblox \
  --url https://infoblox.example.com \
  --username admin \
  --password-file ~/.config/onedns/infoblox-pass
```

### BlueCat

```bash
onedns appliance set bluecat \
  --url https://bluecat.example.com \
  --api-key-file ~/.config/onedns/bluecat-key
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `ONEDNS_CONFIG` | Path to config file |
| `ONEDNS_OUTPUT_LEVEL` | Default output level |
| `ONEDNS_RESOLVER` | Default DNS resolver |
| `ONEDNS_DNSSCIENCE_KEY` | dnsscience.io API key |

## Troubleshooting

### Command not found

Ensure `$GOPATH/bin` is in your PATH:

```bash
export PATH=$PATH:$(go env GOPATH)/bin
```

Add to `~/.bashrc` or `~/.zshrc` for persistence.

### Permission denied

If building from source:
```bash
chmod +x onedns
```

### DNS resolution issues

Test basic connectivity:
```bash
onedns query google.com --server 8.8.8.8
```

## Uninstall

```bash
rm /usr/local/bin/onedns
rm -rf ~/.config/onedns
```
