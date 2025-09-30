# Test Plan (v0.1)

Latency loopback benchmarks
- Single-send/receive roundtrip with committee aggregation (local process).
- Measure:
  - Validation time per block and ensure it stays within strict low-latency bounds.
  - Aggregation time for k-of-n (k=22, n=32).
  - Serialization/deserialization effort remains lightweight.

Functional
- Send then Receive updates balances and heads correctly.
- Double-spend rejected after first QC.
- Rate limiter blocks excessive tx bursts; allows sustained 1 tx/s.
- Committee selection stability (same inputs => same committee).
- QC only produced with consistent block_hash and ≥ threshold votes.

Adversarial
- Byzantine voters send wrong partials: aggregation rejects.
- Conflicting votes: ensure aggregator ties to a single block_hash.
- Partial network partitions: early QC wins, late conflicting blocks rejected.

Interoperability
- Canonical JSON hashing test vectors for blocks, votes, QCs.
- Cross-implementation harness: encode/decode roundtrips.