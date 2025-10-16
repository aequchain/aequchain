# Simulation Scale Notes

## Current Footprint
- **Process model:** The `InMemoryNode` keeps all state in RAM—no disk IO and no external services. When the Julia process exits, all data is discarded.
- **State storage:**
  - Accounts live in `State.StateDB.accounts :: Dict{AccountID, AccountState}`. Storage grows linearly with the number of people you register.
  - Blocks and quorum certificates append to `Vector`s. Each payment generates two blocks (send/receive) and two QCs.
- **Consensus math:** Committees are deterministic samples drawn with `select_committee`. Defaults: `committee_size = 8`, `threshold = 5`, but both can be tuned via `NodeConfig`.
- **Rate limiting:** One token bucket per account. Each entry is constant-sized metadata; growth is linear in the member count.

## Practical Capacity Today
| Component | Limiting Factor | Notes |
|-----------|-----------------|-------|
| Accounts | Available RAM | 100k+ accounts are feasible on a mid-range laptop (\~64 bytes per `AccountState`). |
| Blocks    | Available RAM | 1 million blocks is \~200 MB of data; manageable locally if you keep sessions short. |
| Committees | CPU            | Selection is `shuffle!` over the member list. For large networks, pre-shuffling or chunking becomes important. |
| Rate limiting | CPU | Each transfer touches one bucket lookup and timestamp delta; negligible until you reach >10k tx/s. |

All resource usage scales linearly—no hidden quadratic spikes—as long as you avoid recomputing committees over the entire member list every microsecond.

## Knobs to Grow the Simulation
1. **NodeConfig tweaks**
   ```julia
   node = InMemoryNode(NodeConfig(committee_size=128, threshold=96, epoch_seed=0x1234))
   ```
   Larger committees give you stronger safety assumptions when you simulate a global population.
2. **Batch registration**
   ```julia
   for i in 1:100_000
       register_account!(node, "member-$(i)"; initial_balance=UInt128(0))
   end
   ```
   The loop cost is dominated by dictionary inserts; expect roughly 50–100 ms per 10k registrations on modern hardware.
3. **Synthetic traffic**
   ```julia
   using Random
   members = collect(node.members)
   for _ in 1:50_000
       from, to = rand(MersenneTwister(42), members, 2)
       submit_payment!(node, from, to, UInt128(1))
   end
   ```
   Randomized transfers help surface committee rotations and rate-limiter behavior under load.

## What Global Scale Still Needs
- **Multi-node execution:** Currently the simulation is single-process. To reach a planetary footprint, introduce lightweight networking (e.g., local sockets or in-process message passing) so several `InMemoryNode`s share events.
- **Persistent checkpoints:** Even though we stay ephemeral for free access, storing occasional snapshots (to RAM disk or encrypted swap) makes it easier to resume long experiments without rewriting history.
- **Committee precomputation:** For millions of members, compute committee assignments per epoch once and reuse them to avoid repeated shuffles.
- **Observability:** The CLI now ships with `node_status` and `node_metrics` so you can watch throughput, latency, and memory projections live. For deeper scale runs, extend those counters with queue depth and committee fill-rate sampling.

## Staying Free and Offline
Everything above uses the local Julia runtime—no third-party SaaS, no paid APIs. Use the CLI metrics panels to record headline numbers (latency, tx/s, projected headroom at 4 GB or 8 GB) while you scale experiments. The ledger remains RAM-only and completely under your control.
