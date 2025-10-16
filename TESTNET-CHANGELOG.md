# Changelog - aequchain Testnet Demo

## [Unreleased] - 2025-10-16

### Added - Interactive Web Demo

#### New Flutter Web Application
- **Location**: `aequchain_testnet_dapp/`
- **Framework**: Flutter 3.x with Dart
- **Interface**: Web-based UI on http://localhost:43255
- **Features**:
  - Live Accounts Dashboard with real-time updates
  - Account creation with æ (aequus) currency
  - Transaction sending with balance updates
  - Transaction history with hashes and timestamps
  - Blockchain evidence display with network stats
  - Full server reset capability with confirmation
  - Mobile-first responsive design
  - Black-on-white minimalist aesthetic
  - "IN USE" badges for taken account names
  - Safety banner: "100% Safe Demo Environment"

#### New API Server
- **Location**: `files/src/network/APIServer.jl`
- **Framework**: HTTP.jl with JSON3.jl
- **Interface**: RESTful API on http://localhost:3000
- **Endpoints**:
  - `POST /api/testnet/reset` - Clear all server data
  - `POST /api/testnet/account/create` - Create accounts
  - `GET /api/testnet/account/:id/balance` - Get balance
  - `GET /api/testnet/accounts` - List all accounts with balances **(NEW)**
  - `POST /api/testnet/transaction/send` - Send transactions
  - `GET /api/testnet/stats` - Network statistics
  - `POST /api/testnet/content/publish` - Publish content
  - `GET /api/testnet/content/list` - List published content
- **Features**:
  - CORS enabled for web client
  - In-memory ephemeral storage
  - Demo mode indicators
  - Error handling and validation

#### New Core Modules
- `files/src/node/InMemoryNode.jl` - Single-node testnet implementation
- `files/src/state/StateDB.jl` - In-memory state management
- `files/src/types/Types.jl` - Core blockchain types
- `start-api.jl` - API server launcher script

#### New Scripts & Tools
- `bin/start-demo.sh` - Launch full demo (API + Flutter)
- `bin/launch-flutter-only.sh` - Launch Flutter UI only
- `bin/test-installation.sh` - Verify installation and dependencies
- `bin/quickcheck.sh` - Quick API health check

#### New Documentation
- `TESTNET-DEMO-README.md` - Complete demo guide
- `REQUIREMENTS.md` - Detailed dependency requirements
- `TESTNET-OPERATIONAL.md` - Technical status document
- `BRANDING-UPDATE-aequchain-lowercase.md` - Branding changes log

#### Configuration Files
- `Project.toml` - Julia package dependencies
- `Manifest.toml` - Locked Julia dependency versions
- `aequchain_testnet_dapp/pubspec.yaml` - Flutter dependencies
- `aequchain_testnet_dapp/pubspec.lock` - Locked Flutter versions

### Changed - Branding Updates

#### Naming Convention
- Changed all instances of "AequChain" to "**aequchain**" (lowercase, bold)
- Updated module names, file paths, documentation
- Consistent use across:
  - Code files (.jl, .dart)
  - Documentation (.md)
  - Configuration files (.toml, .yaml)
  - Shell scripts (.sh)
  - API responses
  - UI displays

#### Updated Files
- `README.md` - Added demo quick start section
- `files/src/AequChain.jl` - Module documentation
- `files/docs/aequchain-spec.md` - Technical specification
- `files/docs/roadmap.md` - Project roadmap
- API server banner - Shows "**aequchain** Testnet API Server"

### Technical Details

#### Architecture
```
aequchain/
├── start-api.jl              # API server entry point
├── Project.toml              # Julia dependencies
├── Manifest.toml             # Locked versions
├── bin/
│   ├── start-demo.sh         # Full demo launcher
│   ├── launch-flutter-only.sh
│   ├── test-installation.sh  # Verification script
│   └── quickcheck.sh
├── files/src/
│   ├── AequChain.jl          # Main module
│   ├── types/Types.jl        # Core types
│   ├── state/StateDB.jl      # State management
│   ├── node/InMemoryNode.jl  # Testnet node
│   └── network/APIServer.jl  # HTTP server
└── aequchain_testnet_dapp/
    ├── pubspec.yaml          # Flutter config
    ├── lib/
    │   └── main.dart         # Flutter UI (1190+ lines)
    └── web/
        └── index.html        # Web entry point
```

#### Dependencies
**Julia** (1.8+):
- HTTP.jl v1.10+
- JSON3.jl v1.14+
- SHA.jl v0.7+

**Flutter** (3.0+):
- http ^1.2.0
- flutter (SDK)

#### Features Demonstrated
- ✅ Account management (create, query balance)
- ✅ Transaction processing (send/receive)
- ✅ Real-time state updates
- ✅ Live dashboard with all accounts
- ✅ Transaction history tracking
- ✅ Blockchain evidence (hashes, timestamps, stats)
- ✅ Full reset capability for demos
- ✅ Mobile-responsive UI
- ✅ æ (aequus) demo currency

#### Limitations
- ⚠️ In-memory only (no persistence)
- ⚠️ Single-node (no network consensus)
- ⚠️ Demo hashes only (not cryptographic)
- ⚠️ No real monetary value
- ⚠️ Ephemeral (resets clear all data)
- ⚠️ Not production-ready

### Security Notes
- All data is ephemeral (RAM only)
- No persistent storage or blockchain writes
- Demo mode clearly indicated in all responses
- Safe for testing and demonstrations
- Zero real monetary value
- Restarts clear all state

### Testing
- Manual testing completed on Ubuntu 22.04
- Julia 1.12.0 verified
- Flutter 3.35.4 verified
- All API endpoints functional
- UI responsive on desktop and mobile
- Auto-refresh working correctly
- Reset functionality confirmed

### Installation Requirements
See `REQUIREMENTS.md` for complete details:
- Operating System: Linux, macOS, or Windows (WSL2)
- Julia 1.8+
- Flutter 3.0+
- Ports 3000 and 43255 available
- bash shell
- Internet (for initial package downloads)

### Quick Start
```bash
# Clone repository
git clone https://github.com/ttx89-dev/Universal-Equity-Blockchain.git
cd Universal-Equity-Blockchain/aequchain

# Install dependencies
julia --project=. -e 'using Pkg; Pkg.instantiate()'
cd aequchain_testnet_dapp && flutter pub get && cd ..

# Run demo
./bin/start-demo.sh

# Or test installation first
./bin/test-installation.sh
```

### Future Enhancements (Not Yet Implemented)
- [ ] Persistent blockchain storage
- [ ] Multi-node network consensus
- [ ] Real cryptographic signatures
- [ ] P2P networking
- [ ] Docker containerization
- [ ] CI/CD pipeline
- [ ] Automated test suite
- [ ] Performance benchmarks
- [ ] Security audit
- [ ] Production deployment guide

### Breaking Changes
None - This is all new functionality added to the existing aequchain codebase.

### Deprecations
None

### Contributors
- AI-assisted development (GitHub Copilot)
- Built with aequus design principles
- Following UEB equality manifesto

### License
MIT License - See LICENSE file

---

## Previous Versions

See main repository history for pre-testnet changes.

This changelog documents the addition of the interactive web-based testnet demo to the existing aequchain blockchain implementation.

---

Last updated: October 16, 2025
