# Testnet CLI health routine

Need a repeatable way to convince yourself that the demo ledger is still safe, deterministic, and equal? Run this quick loop whenever you pull fresh changes or before you share a branch.

## 1. Launch the CLI in demo mode

```bash
julia aequchain.jl cli
```

You will land in the interactive prompt with the full aequchain demo environment loaded in memory.

## 2. Fire the consensus and equality spot checks

From inside the CLI run the three canonical commands in order:

```text
consensus_test

equality_check

node_status
```

- `consensus_test` exercises deterministic committee selection, quorum aggregation, duplicate vote handling, insufficient vote rejection, and conflicting-hash detection.
- `equality_check` inspects the live in-memory ledger, confirming that the treasury share math, member registries, network memberships, 30-day spending limits, and business/pledge references all hold the equality invariant. Add `--format=json` for machine-readable output or combine with `--output equality.json` to persist the structured payload for audits.
- `node_status` gives a quick snapshot of accounts, throughput, latency, and memory so you can confirm nothing unexpected shifted between runs.

Press Enter after each report to return to the prompt.

## 3. Run the automated quickcheck bundle (optional)

Back in a shell, execute the helper script to replay the deterministic test suite that the CLI commands rely on:

```bash
./bin/quickcheck.sh
```

This script chains the hash determinism test, the in-memory node payments test, and the consensus test. It is safe to run repeatedly; it leaves no state behind.

> **Why no hosted CI?** To keep the project free for everyone, we avoid GitHub Actions minutes entirely. The quick health routine above delivers the same assurance locally without incurring usage charges.
