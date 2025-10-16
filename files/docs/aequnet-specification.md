# AequNet Content Distribution Protocol Specification
## Version 0.1 - Demo Implementation

---

## Overview

**AequNet** is a decentralized content distribution network where every node contributes to storing and serving content. It uses a Distributed Hash Table (DHT) for content location, blockchain anchoring for authenticity, and optional encryption for privacy.

## Architecture

### Components

1. **Content Chunking**: Large files split into 256KB chunks (Fibonacci-adjacent 2^18)
2. **DHT Network**: Kademlia-inspired routing for content location
3. **Blockchain Anchoring**: Content manifests anchored in blockchain blocks
4. **Node Registry**: Tracks which nodes host which content
5. **Reputation System**: Rewards reliable nodes with better scores

### Content Flow

#### Publishing Content

```
1. User creates content (HTML/CSS/JS/images/etc)
2. Content chunked into 256KB pieces
3. Each chunk hashed (SHA256 for demo, Blake3 for production)
4. Manifest created linking all chunks
5. Manifest hash anchored in blockchain
6. Chunks distributed to DHT (5 replicas - Fibonacci)
7. Publisher's account updated with content references
```

#### Retrieving Content

```
1. Request comes for content hash
2. DHT queried for nodes hosting chunks
3. Chunks retrieved from nearest/fastest nodes
4. Integrity verified against manifest
5. Blockchain validates manifest authenticity
6. Content assembled and served
```

## Data Structures

### ContentChunk

```julia
struct ContentChunk
    hash::Hash              # SHA256 of chunk data
    data::Vector{UInt8}     # Raw chunk bytes
    size::Int64             # Chunk size (max 256KB)
end
```

### ContentManifest

```julia
struct ContentManifest
    root_hash::Hash                        # Hash of entire content
    chunks::Vector{Hash}                   # Ordered chunk hashes
    metadata::ContentMetadata              # Title, description, etc.
    timestamp::Int64                       # Creation time
    publisher::AccountID                   # Who published it
    encryption::Union{EncryptedContent,Nothing}  # Optional encryption
    signature::Vector{UInt8}               # Publisher's signature
end
```

### ContentMetadata

```julia
struct ContentMetadata
    title::String
    description::String
    content_type::String      # MIME type
    tags::Vector{String}
    created_at::Int64
    file_size::Int64
end
```

## DHT Protocol

### Node Structure

```julia
struct DHTNode
    node_id::AccountID      # Unique node identifier
    address::String         # IP:Port
    last_seen::Int64        # Last activity timestamp
    reputation::Float64     # 0.0 to 1.0
end
```

### Routing

- **XOR Distance Metric**: Nodes are organized by XOR distance
- **K-Bucket Size**: 8 closest nodes (Fibonacci)
- **Parallel Lookups**: 3 concurrent queries (Fibonacci)
- **Replication Factor**: 5 nodes per content (Fibonacci)

### Node Discovery

```
1. Bootstrap from known nodes
2. Ping neighbors to find closer nodes
3. Build routing table of closest peers
4. Periodic refresh (987 seconds - Fibonacci)
```

### Content Location

```
1. Compute content hash
2. Find K closest nodes to hash
3. Query nodes for content
4. Return list of hosting nodes
5. Prefer high-reputation nodes
```

## Integrity Verification

### Hash Chain

```
chunk_1_hash = SHA256(chunk_1_data)
chunk_2_hash = SHA256(chunk_2_data)
...
root_hash = SHA256(chunk_1_hash || chunk_2_hash || ... || chunk_n_hash)
```

### Verification Steps

1. Retrieve all chunks
2. Recompute chunk hashes
3. Compare to manifest chunk hashes
4. Recompute root hash
5. Compare to manifest root hash
6. Verify publisher signature on manifest
7. Check blockchain anchor

## Reputation System

### Reputation Score Calculation

```julia
reputation = 0.5 * (content_served / 1000) + 
             0.5 * (content_diversity / 100)

# Clamped to [0.0, 1.0]
```

### Reputation Affects

- **Content Storage Priority**: High reputation nodes selected first
- **Query Preference**: Users prefer high reputation nodes
- **Network Standing**: May affect future features

### Reputation Updates

- **Content Served**: +0.001 per successful serve
- **Failed Request**: -0.01
- **Offline**: -0.1 per day offline
- **Stale (377s - Fibonacci)**: Removed from DHT

## Optional Encryption

### Symmetric Encryption (AES-256)

```
1. Generate random AES-256 key
2. Encrypt chunks with key
3. Encrypt key with recipient public keys
4. Store encrypted key in manifest
5. Only authorized accounts can decrypt
```

### Access Control

```julia
@enum AccessLevel begin
    PUBLIC = 0           # Anyone can access
    MEMBERS_ONLY = 1     # Any member can access
    RESTRICTED = 2       # Specific accounts only
end
```

## Blockchain Integration

### Content Anchoring

```
SendBlock or ReceiveBlock includes:
- content_manifest_hash (in block metadata)
- Proves content existed at block time
- Links content to publisher identity
- Enables verification of authenticity
```

### Publisher Verification

```
1. Retrieve content manifest
2. Get publisher's AccountID from manifest
3. Query blockchain for publisher's public key
4. Verify signature on manifest
5. Confirm publisher identity tier
```

## Performance Targets

### Latency

- **Content Location**: <200ms (p95)
- **Small File Retrieval**: <500ms (p95)
- **Large File (10MB)**: <3s (p95)
- **DHT Update Propagation**: <1s

### Throughput

- **Per Node**: 50 req/s sustained
- **Network**: Scales linearly with nodes
- **Storage per Node**: 1-10GB recommended

### Availability

- **Replication Factor 5**: 99.99% availability
- **Stale Node Removal**: 377s (Fibonacci)
- **Content TTL**: 89 days (Fibonacci) minimum

## Security Considerations

### Threat Model

1. **Malicious Content**: Sandboxed execution, no script tags
2. **Content Poisoning**: Integrity checks prevent
3. **Sybil Attacks**: PoP prevents identity abuse
4. **DDoS**: Rate limiting per identity tier
5. **Storage Exhaustion**: Upload limits per tier

### Mitigations

- **Content Sandboxing**: CSP headers, no execution
- **Hash Verification**: All content verified
- **Identity Requirements**: Must be registered
- **Rate Limiting**: Tier-based upload limits
- **Reputation**: Bad actors lose reputation

## API Endpoints

### Publish Content

```
POST /api/content/publish
Body: {
  "publisher": "account_id",
  "content": "base64_encoded_data",
  "title": "My Content",
  "description": "Description",
  "content_type": "text/html",
  "tags": ["tag1", "tag2"],
  "access_level": 0,
  "authorized_accounts": []
}
Response: {
  "success": true,
  "data": {
    "content_hash": "abc123...",
    "chunks": 42,
    "stored_at": ["node1", "node2", ...]
  }
}
```

### Retrieve Content

```
GET /api/content/:hash
Response: {
  "success": true,
  "data": {
    "content": "base64_encoded_data",
    "metadata": {...},
    "verified": true
  }
}
```

### List Content

```
GET /api/content?tags=tag1,tag2&publisher=account_id
Response: {
  "success": true,
  "data": {
    "contents": [...]
  }
}
```

## Demo Mode Limitations

⚠️ **Demo Mode Restrictions**:

- Maximum content size: 10MB
- Maximum 987 total contents (Fibonacci)
- Content not persisted across restarts
- No real network distribution (simulated)
- No encryption in demo mode
- Local storage only

## Future Enhancements

### Post-Demo

- Real P2P networking (libp2p)
- Blake3 hashing (faster)
- BLS signature aggregation
- IPFS integration option
- CDN-like edge caching
- Streaming support
- Torrent-like swarming
- Mobile node support

### Production Requirements

- Persistent content storage
- Real network propagation
- Encryption enabled
- DDoS protection
- Legal content filtering
- DMCA compliance
- Bandwidth accounting
- Payment for storage (optional)

---

## Implementation Files

- `/aequchain/files/src/types/ContentTypes.jl` - Data structures
- `/aequchain/files/src/network/ContentDHT.jl` - DHT implementation
- `/aequchain/files/src/network/ContentServer.jl` - Content management
- `/aequchain/files/configs/aequnet.toml` - Configuration

---

**Status**: Demo implementation complete, production enhancements needed.
