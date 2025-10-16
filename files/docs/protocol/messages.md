# aequchain Wire Formats (v0.1)

All messages are JSON for v0.1 (to ease debugging). Later: protobuf for efficiency.
All binary fields are base64url-encoded strings.

Common
- id: string (UUID v4)
- type: string
- ts: number (ms since epoch)
- net: string (network id, e.g., "aequchain-mainnet-v0", "testnet")

1) Block: Send
{
  "id": "uuid",
  "type": "block/send",
  "ts": 1690000000000,
  "net": "aequchain-testnet",
  "header": {
    "account_id": "acc_... (PoP ID or pubkey hash)",
    "prev_head": "hash",
    "height": 42,
    "state_root_hint": "hash",
    "nonce": 12345,
    "timestamp": 1690000000000,
    "payload_hash": "hash"
  },
  "payload": {
    "to_account": "acc_...",
    "amount": "1000",
    "transfer_id": "hash"
  },
  "proofs": {
    "state": [
      { "key": "acc_...", "value": { "balance":"...", "head":"...", "nonce": 12344 }, "merkle_proof": ["hash", "..."] }
    ]
  },
  "sig": "ed25519sig"
}

2) Block: Receive
{
  "id": "uuid",
  "type": "block/receive",
  "ts": 1690000000001,
  "net": "aequchain-testnet",
  "header": { ... same fields ... },
  "payload": {
    "from_account": "acc_...",
    "transfer_id": "hash"
  },
  "proofs": {
    "state": [
      { "key": "acc_...", "value": { "unspent_transfers":[ "hash", ... ] }, "merkle_proof": ["hash", "..."] }
    ]
  },
  "sig": "ed25519sig"
}

3) Vote (committee partial)
{
  "id": "uuid",
  "type": "consensus/vote",
  "ts": 1690000000100,
  "net": "aequchain-testnet",
  "block_hash": "hash",
  "committee_epoch": 123,
  "committee_id": "cid_... (derived from seed+account+seq)",
  "member_id": "acc_... (committee member identity id)",
  "partial_sig": "ed25519sig-over-block-hash",
  "bitmap_index": 17
}

4) Quorum Certificate (QC)
{
  "id": "uuid",
  "type": "consensus/qc",
  "ts": 1690000000200,
  "net": "aequchain-testnet",
  "block_hash": "hash",
  "committee_epoch": 123,
  "committee_id": "cid_...",
  "agg_sig": "aggSig (multisig/BLS)",
  "bitmap": "base64 compressed bitmap",
  "members": ["acc_...","acc_..."],  // optional in v0.1 if agg proof not self-contained
  "threshold": 22
}

5) Rep Registration / Delegation Update
{
  "id": "uuid",
  "type": "rep/register",
  "ts": 1690000000000,
  "net": "aequchain-testnet",
  "rep_id": "acc_...",
  "metadata": { "endpoint": "ip:port", "features": ["relay"] },
  "sig": "ed25519sig"
}
{
  "id": "uuid",
  "type": "rep/delegate",
  "ts": 1690000000000,
  "net": "aequchain-testnet",
  "account_id": "acc_...",
  "rep_id": "acc_...",
  "sig": "ed25519sig"
}

6) Gossip (envelope)
{
  "id": "uuid",
  "type": "gossip",
  "ts": 1690000000300,
  "net": "aequchain-testnet",
  "topic": "block|vote|qc|rep",
  "payload": { ... any of the above ... }
}

7) Committee Selection (debug/telemetry)
{
  "id": "uuid",
  "type": "committee/announce",
  "ts": 1690000000000,
  "net": "aequchain-testnet",
  "committee_epoch": 123,
  "committee_id": "cid_...",
  "members": ["acc_...","acc_..."]  // not required for consensus; for observability
}

Notes
- All hashes: SHA-256 over canonical JSON (sorted keys). Later: SSZ/CBOR or protobuf.
- Signature scheme v0.1: Ed25519. Aggregation: multisig (collect and store bitmap + partials), BLS later.
- Backpressure:
  - Votes include bitmap_index; aggregator uses this to build QC efficiently.
  - If vote timeouts occur, sender increases fanout or hands off aggregation to rep.