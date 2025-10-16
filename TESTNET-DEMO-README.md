# **aequchain** Testnet Demo

## 🚀 Quick Start Demo

This is a **100% safe, ephemeral testnet** for demonstrating **aequchain**'s blockchain capabilities. Nothing is written permanently - all data clears on restart.

### Requirements

- **Julia 1.8+** (tested with 1.12.0)
- **Flutter 3.x+** (tested with 3.35.4)
- **Linux/macOS** (bash shell)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ttx89-dev/Universal-Equity-Blockchain.git
   cd Universal-Equity-Blockchain/aequchain
   ```

2. **Install Julia dependencies**:
   ```bash
   julia --project=. -e 'using Pkg; Pkg.instantiate()'
   ```

3. **Install Flutter dependencies**:
   ```bash
   cd aequchain_testnet_dapp
   flutter pub get
   cd ..
   ```

### Run the Demo

**Option 1: Full Demo (API + Flutter UI)**
```bash
./bin/start-demo.sh
```

This starts:
- **API Server** on http://localhost:3000
- **Flutter Web App** on http://localhost:43255

**Option 2: API Server Only**
```bash
julia --project=. start-api.jl
```

**Option 3: Flutter UI Only** (requires API server running)
```bash
./bin/launch-flutter-only.sh
```

### What You'll See

#### Live Accounts Dashboard
- Shows all active accounts with æ (aequus) balances
- Displays active nodes, total accounts, and transactions
- "IN USE" badges show which account names are taken
- Auto-refreshes after every operation

#### Create Account
- Enter any unique account name
- Automatically receives æ1000 initial balance
- Dashboard updates instantly

#### Send Transaction
- Transfer æ between accounts
- Real-time balance updates
- Transaction history with hashes and timestamps

#### Demo Safety Features
- Green banner: "100% Safe Demo Environment"
- UI Reset button (clears local display)
- Full Server Reset button (wipes all server data)
- Confirmation dialog prevents accidental resets

### API Endpoints

All endpoints available at `http://localhost:3000`:

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/testnet/reset` | Clear all server data |
| POST | `/api/testnet/account/create` | Create new account |
| GET | `/api/testnet/account/:id/balance` | Get account balance |
| GET | `/api/testnet/accounts` | List all accounts with balances |
| POST | `/api/testnet/transaction/send` | Send transaction |
| GET | `/api/testnet/stats` | Get network statistics |
| POST | `/api/testnet/content/publish` | Publish content (AequNet demo) |
| GET | `/api/testnet/content/list` | List published content |

### Example API Usage

**Create Account**:
```bash
curl -X POST http://localhost:3000/api/testnet/account/create \
  -H "Content-Type: application/json" \
  -d '{"account_id":"alice"}'
```

**Send Transaction**:
```bash
curl -X POST http://localhost:3000/api/testnet/transaction/send \
  -H "Content-Type: application/json" \
  -d '{"from":"alice","to":"bob","amount":100}'
```

**List All Accounts**:
```bash
curl http://localhost:3000/api/testnet/accounts | jq .
```

**Get Statistics**:
```bash
curl http://localhost:3000/api/testnet/stats | jq .
```

### Features Demonstrated

✅ **Account Management** - Create accounts, check balances  
✅ **Transactions** - Send/receive æ currency  
✅ **Real-time Dashboard** - Live view of all accounts and balances  
✅ **Blockchain Evidence** - Transaction hashes, timestamps, network stats  
✅ **Demo Safety** - Full reset capability, ephemeral storage  
✅ **Mobile Responsive** - Works on desktop and mobile browsers  
✅ **Beautiful UI** - Black-on-white minimalist design with Fibonacci animations  

### Architecture

```
aequchain/
├── start-api.jl                  # API server launcher
├── files/src/
│   ├── AequChain.jl             # Main module
│   ├── types/Types.jl           # Core types
│   ├── state/StateDB.jl         # In-memory state
│   ├── node/InMemoryNode.jl     # Testnet node
│   └── network/APIServer.jl     # HTTP API endpoints
└── aequchain_testnet_dapp/
    └── lib/main.dart            # Flutter UI
```

### Technical Details

**Currency**: æ (aequus) - demo currency symbol  
**Initial Balance**: æ1000 per account  
**Hash Algorithm**: Demo SHA-256 hashes (8-char display)  
**Storage**: In-memory only (ephemeral)  
**Consensus**: Single-node testnet (no network consensus)  
**State**: Cleared on server restart or manual reset  

### Troubleshooting

**Port Already in Use**:
```bash
# Kill processes on port 3000
lsof -ti:3000 | xargs kill -9

# Kill processes on port 43255
lsof -ti:43255 | xargs kill -9
```

**Flutter Build Issues**:
```bash
cd aequchain_testnet_dapp
flutter clean
flutter pub get
```

**Julia Package Issues**:
```bash
julia --project=. -e 'using Pkg; Pkg.resolve(); Pkg.instantiate()'
```

### Limitations

⚠️ **This is a DEMO TESTNET**:
- No persistent storage (all data in RAM)
- No network consensus (single node)
- No cryptographic security (demo hashes)
- No real monetary value (æ currency is fictional)
- Restarts clear all data
- Not suitable for production use

### What's Next?

This demo showcases the **user experience** and **API design** of **aequchain**. 

For production deployment, the following are required:
- Persistent blockchain storage
- Multi-node consensus mechanism
- Real cryptographic signatures
- Network P2P communication
- Security audits
- Compliance review (KYC/AML)
- Formal verification of equality guarantees

See the main [README.md](README.md) for the full **aequchain** vision and capabilities.

### Contributing

This is a demo/research project. See [GITHUB_AGENTS.md](GITHUB_AGENTS.md) for contribution guidelines.

### License

MIT License - See [LICENSE](LICENSE)

### Support

For questions or issues with the demo:
- Check [TESTNET-OPERATIONAL.md](TESTNET-OPERATIONAL.md) for detailed status
- Review [files/docs/](files/docs/) for technical documentation
- Open an issue on GitHub

---

**Remember**: This is a **safe sandbox** for experimentation. Feel free to create accounts, send transactions, and explore the UI. Click "Full Server Reset" anytime to start fresh! 🎉
