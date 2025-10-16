# Requirements for aequchain Testnet Demo

## System Requirements

### Operating System
- Linux (tested on Ubuntu 22.04+)
- macOS (tested on 12.0+)
- Windows with WSL2

### Shell
- bash 4.0+

## Software Dependencies

### Julia
- **Version**: 1.8 or higher (tested with 1.12.0)
- **Download**: https://julialang.org/downloads/
- **Installation check**: `julia --version`

### Flutter
- **Version**: 3.0 or higher (tested with 3.35.4)
- **Download**: https://flutter.dev/docs/get-started/install
- **Installation check**: `flutter --version`

### Required Flutter Components
- Dart SDK (comes with Flutter)
- Flutter web support enabled: `flutter config --enable-web`

### System Tools
- `curl` - For API testing
- `jq` - For JSON formatting (optional but recommended)
- `lsof` or `fuser` - For port management (cleanup scripts)

## Julia Package Dependencies

These are automatically installed via `Project.toml`:

- **HTTP.jl** (v1.10+) - API server
- **JSON3.jl** (v1.14+) - JSON handling
- **SHA.jl** (v0.7+) - Hashing utilities

Install with:
```bash
cd aequchain
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

## Flutter Package Dependencies

These are automatically installed via `pubspec.yaml`:

- **http** (^1.2.0) - API client
- **flutter** (SDK) - Flutter framework

Install with:
```bash
cd aequchain/aequchain_testnet_dapp
flutter pub get
```

## Port Requirements

The demo requires these ports to be available:

- **3000** - Julia API server
- **43255** - Flutter web server

If ports are in use, you can kill processes:
```bash
lsof -ti:3000 | xargs kill -9
lsof -ti:43255 | xargs kill -9
```

## Minimum Hardware

- **RAM**: 2GB available
- **Disk**: 500MB for dependencies
- **CPU**: Any modern processor

## Network

- Internet connection required for initial package downloads
- After installation, demo runs completely offline
- No external API calls or blockchain connections

## Verification Commands

Check all requirements:
```bash
# Julia
julia --version

# Flutter
flutter --version
flutter doctor

# System tools
curl --version
jq --version  # optional
lsof -v

# Ports available
lsof -i:3000 && echo "Port 3000 in use" || echo "Port 3000 free"
lsof -i:43255 && echo "Port 43255 in use" || echo "Port 43255 free"
```

## Installation Guide

### Ubuntu/Debian
```bash
# Julia
wget https://julialang-s3.julialang.org/bin/linux/x64/1.12/julia-1.12.0-linux-x86_64.tar.gz
tar xvf julia-1.12.0-linux-x86_64.tar.gz
sudo mv julia-1.12.0 /opt/
sudo ln -s /opt/julia-1.12.0/bin/julia /usr/local/bin/julia

# Flutter
sudo snap install flutter --classic
flutter config --enable-web

# Tools
sudo apt install curl jq lsof
```

### macOS
```bash
# Julia
brew install julia

# Flutter
brew install --cask flutter
flutter config --enable-web

# Tools (usually pre-installed)
brew install curl jq
```

### Windows (WSL2)
```bash
# Install WSL2 first
wsl --install

# Then follow Ubuntu instructions inside WSL
```

## Troubleshooting

### Julia not found
Add Julia to PATH:
```bash
export PATH="$PATH:/opt/julia-1.12.0/bin"
```

### Flutter command not found
```bash
export PATH="$PATH:$HOME/snap/flutter/common/flutter/bin"
```

### Package installation fails
Clear cache and retry:
```bash
# Julia
julia --project=. -e 'using Pkg; Pkg.gc(); Pkg.resolve(); Pkg.instantiate()'

# Flutter
cd aequchain_testnet_dapp
flutter clean
flutter pub get
```

### Ports already in use
```bash
# Find and kill processes
sudo lsof -ti:3000 | xargs kill -9
sudo lsof -ti:43255 | xargs kill -9
```

## Docker Alternative (Future)

For a containerized setup (not yet implemented), this would include:
- Dockerfile for Julia API server
- docker-compose.yml for full stack
- Pre-built images on Docker Hub

Contributions welcome!

## Minimal Setup

If you just want to test the API without the Flutter UI:

Requirements:
- Julia 1.8+
- curl (for testing)

Run:
```bash
cd aequchain
julia --project=. start-api.jl
```

Test:
```bash
curl http://localhost:3000/
curl -X POST http://localhost:3000/api/testnet/account/create \
  -H "Content-Type: application/json" \
  -d '{"account_id":"alice"}'
```

## Support

For issues:
1. Check `flutter doctor` output
2. Verify `julia --version` is 1.8+
3. Ensure ports 3000 and 43255 are free
4. Review [TESTNET-DEMO-README.md](TESTNET-DEMO-README.md) for setup details

---

Last updated: October 2025
