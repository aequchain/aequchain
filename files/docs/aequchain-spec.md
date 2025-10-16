# aequchain Protocol v0.1 (Nano-class, Equality-Preserving)

Goals
- Near-real-time end-to-end confirmations at all scales.
- Equality by design: one-human-one-identity, no stake/miner advantage, no fees.
- Mobile-first: low CPU, small storage, minimal bandwidth.
- Horizontal scalability: throughput grows with participants via account-chains and per-tx micro-committees.
- Safety: single-round finality in the common case with aggregated quorum certificates (QCs).

Core Model
- Account-chains (block-lattice-style):
  - Each account maintains an append-only chain.
  - Two block types:
    - SendBlock: reduces sender balance, creates an unspent transfer for the recipient.
    - ReceiveBlock: consumes a matching unspent transfer, credits recipient.
  - Double-spends are local: two different children of the same account-head.

- State commitment:
  - Global state is a key-value map AccountID -> AccountState {balance, head_hash, nonce, rep_id}.
  - Maintain a Merkle or Verkle trie root (StateRoot). Initially: Merkle-Patricia lite (Merkle-map).
  - Blocks carry proofs (Merkle proofs) for touched accounts to enable O(log N) verification.

- Representatives (availability, not power):
  - Each identity can optionally delegate availability to a Rep for low-latency responsiveness.
  - Every identity equals one vote. Delegation transfers only availability, not power weighting.
  - Delegations are updated instantly via DelegationUpdate transactions (free, rate-limited).

Consensus (single-round, micro-committee)
- Per-block validation by a small micro-committee (e.g., 32 members) randomly selected via VRF:
  committee_seed = VRF(epoch_seed || account_id || block_seq)
- Threshold attestation: committee signs the block; aggregator produces a Quorum Certificate (QC).
- Finality rule (fast path):
  - First QC reaching threshold (t = 2f+1) for a unique child of the account’s head is final.
  - Conflicts (two children) resolve by the first valid QC; others are rejected.
- No stake, no mining, no rewards. Participation equality ensured by:
  - Proof-of-personhood registry (PoP): one-human-one-identity.
  - Equal probability of committee selection across identities.
  - Rotating epoch seeds to prevent grinding.
  - Per-identity rate limits to prevent spam.

Anti-spam and Flow Control
- Token-bucket per identity:
  - Default: sustained throughput calibrated per identity with short burst capacity (up to five consecutive transactions).
  - Adaptive: increase cost (require the lightweight proof-of-admission work) when network under attack.
- Optional lightweight proof-of-admission (former "tiny PoW") only under pressure:
  - Executes quickly on everyday mobile hardware.
  - Never distributes mining rewards or incentives; it exists solely as an admission control signal.

Networking
- Low-fanout, latency-optimized:
  - Sender unicasts to:
    - Their Representative (if any) and
    - Members of the micro-committee (or to a committee-anycast relay if offline).
  - Gossip QCs with proximity bias (select low-latency peers first).
- Transport:
  - Start with TCP for reliability.
  - Add UDP/QUIC for votes/QCs later for lower latency.
- Peer scoring:
  - Maintain RTT and reliability scores; prefer close, reliable peers.

Message Flow (fast path)
1) Sender creates SendBlock S with proofs for sender account state; signs it.
2) Sender pushes S to:
   - Rep (if set), and
   - Selected micro-committee (unicast fanout ≤ 8; rely on relays/gossip for full committee coverage).
3) Committee members validate S:
  - Verify signatures, state proofs, token-bucket allowance and (if enabled) the admission-work check.
   - Check account-head and no-conflict.
   - Sign S; return partial signature.
4) Aggregator (sender or any node) combines k-of-n partials => QC(S).
5) QC(S) is gossiped; recipient can safely craft ReceiveBlock R referencing S.
6) Repeat for R to finalize crediting.

Latency Goals
- Validation, aggregation, and propagation are engineered for responsive user experience.
- End-to-end settlement remains near-real-time across both regional and global scenarios.
- Performance scales independently of network size thanks to constant committee sizes and localized conflict resolution.

Security Model
- Adversary: < f committee members Byzantine per block (with n=32, tolerate f=10).
- Sybil resistance: PoP; committee selection uniform over identities.
- Replay prevention: nonces per account-chain, state proofs bound to StateRoot.
- DoS resistance: per-identity rate limits, adaptive admission-work checks, peer scoring.

Data Structures (conceptual)
- BlockHeader:
  - account_id, prev_head, height, state_root_hint, nonce, timestamp, payload_hash
- SendPayload:
  - to_account, amount, transfer_id (hash), state_proofs (sender)
- ReceivePayload:
  - from_account, transfer_id, state_proofs (recipient)
- Signature: ed25519 signature by account key
- Vote: committee_member_id, partial_sig over block_hash
- QC: aggregate_sig, bitmap, committee_epoch, committee_id, block_hash

Committee Selection
- Epochs: rolling intervals with overlapping membership.
- Seed source: mix of previous QCs and verifiable randomness beacons.
- VRF-based selection:
  - Everyone evaluates VRF(seed, account_id, block_seq).
  - Fixed-size committee determined by sorting VRF outputs or thresholding.
  - Mobile/offline members can designate an availability proxy (rep relay) without transferring vote rights.

Upgrade/Pruning
- Checkpoints every K blocks per account (e.g., 1024): store compact state snapshot.
- Prune old proofs; archive nodes keep full history.
- Protocol versioning via feature flags in block headers and QCs.

Mobile Constraints
- Storage targets:
  - Light node: ≤ 200 MB recent state + proofs + headers.
  - Full node (pruned): ≤ 2–5 GB with checkpoints.
- CPU:
  - Background validation ≤ 5% median smartphone.
- Network:
  - Conservatively sized for light interactive usage on modest data plans.

Parameters (v0.1 defaults)
- committee_size: 32
- threshold: 22
- epoch_duration: 3600 s
- identity_rate_limit: nominal sustained throughput per identity (legacy value `1` corresponds to a once-per-second configuration) with burst capacity of five
- pow_enabled_default: false
- pow_target_ms: 100 (legacy label indicating an admission-work hint; no mining rewards involved)
- gossip_peer_count: 12
- initial_hash: SHA-256; signatures: Ed25519; aggregation: simple multisig (BLS later)

Living for Free Trajectory
- Treasury equality, representative availability, and pledge mechanics jointly drive the system toward internalizing all essential goods.
- No protocol component introduces monetary rewards; contribution is measured in availability and honesty instead of coin minting.
- Progress is observable through freedom indices and checkpoint annotations (see `docs/vision/free-living.md`).

Compatibility with Nano (what’s the same/different)
- Same: account-chains, send/receive model, optional lightweight proof-of-admission for anti-spam.
- Different: equality-preserving voting (1 person = 1 vote), micro-committees with aggregated QC for single-round finality, no stake-weighted ORV, explicit per-identity quotas.

Appendix: Failure Handling
- Conflicting blocks on same head:
  - First QC wins; others rejected.
  - If dual QCs detected due to partition: tie-break by QC timestamp + lexicographic committee hash, slashability not needed (no stake); mark equivocators for reputation penalties.
- Liveness:
  - If insufficient committee responses arrive before the deadline, expand committee fanout or retry the next slot; users can resend.