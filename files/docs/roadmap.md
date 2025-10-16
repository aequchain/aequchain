# AequChain Roadmap (v0.1 → v0.3)

Milestone M0: Skeleton + Local Fast Path
- Types: blocks (send/receive), votes, QC, basic state trie, account model.
- Deterministic committee picker (PRNG seeded by epoch + account + seq).
- Ed25519 keys and signatures; multisig QC (store k partials + bitmap).
- Local loopback network harness; latency/throughput microbenchmarks.
- Token-bucket per-identity rate limiter.
- Optional admission-work stub (legacy PoW nomenclature, off by default, never incentive-bearing).

Milestone M1: P2P + Representatives
- Gossip layer with peer scoring, proximity bias.
- Rep registry (in-protocol messages), delegation updates.
- Anycast-like relay mechanism: client can POST to any rep relay, which forwards to committee.

Milestone M2: Proofs + Pruning
- Merkle-map state with proofs in blocks.
- Checkpoints per account every 1024 blocks.
- Pruned node mode; archive node mode.

Milestone M3: VRF Committees + Aggregation Upgrade
- Replace PRNG with VRF selection.
- BLS aggregate signatures (single-sig QC).
- UDP/QUIC fast path for votes/QCs.

Milestone M4: Hardening + Observability
- Adversarial tests (Byzantine committee members).
- Partition tests; QC conflict detectors.
- Metrics, tracing, dashboards.

Performance Targets to Validate
- Maintain near-real-time confirmations for regional and global usage.
- Keep validator CPU costs minimal per transaction with tight memory footprints.
- Ensure light nodes remain storage- and bandwidth-efficient for everyday devices.

Deliverables by Milestone
- Benchmarks: latency histograms, CPU profiles, memory footprints.
- Interop test vectors: canonical JSON, hash/signature fixtures.
- CLI demo: send, receive, set-rep, delegate, show-balance, show-qc.