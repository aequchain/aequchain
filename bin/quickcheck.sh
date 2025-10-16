#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

echo "==> Running deterministic unit suite"
julia --color=yes --startup-file=no --project=. -e 'using Test; include("files/tests/hash_block_test.jl"); include("files/tests/node_test.jl"); include("files/tests/consensus_test.jl"); include("files/tests/equality_report_test.jl")'

echo
echo "==> Checking equality invariants"
julia --color=yes --startup-file=no --project=. -e 'include("aequchain.jl"); ok = render_equality_report(gather_equality_results(); interactive=false, format=:plain); exit(ok ? 0 : 1)'
