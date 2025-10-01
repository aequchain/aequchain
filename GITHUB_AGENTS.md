# aequchain GitHub Agents & Collaborators Charter

> **Purpose:** Guarantee that every interaction with the repository keeps `main` 100% safe, 100% ephemeral, and 100% faithful to the Universal Equidistributed Blockchain vision of mathematically enforced equality and eventual free living for all.

---

## 1. Immutable Mission & Core Invariants

1. **Equality Equation is Sacred**  
   \(\text{Member\_Value} = \frac{\text{Total Treasury}}{\text{Total Members}}\) must hold after every state mutation. Any proposal that could violate this equation is rejected outright.
2. **Rational{BigInt} Only**  
   All economic values, exchange rates, and treasury balances must use `Rational{BigInt}`. No floating-point shortcuts, ever.
3. **Ephemeral by Default**  
   The `main` branch must remain non-persisting and safe for anyone—from first-time explorers to domain experts—to clone and run without risking real funds or permanent storage. Demo/test code must clean up after itself automatically.
4. **Universal Accessibility**  
   Onboarding, testing, and experimentation must never require payments, staking, or privileged access. Every contribution is assessed for inclusivity impact.
5. **Living-for-Free Trajectory**  
   Each change must either directly advance equality, improve safeguards, or pave the way for free access to essentials (food, housing, energy, healthcare, education). Anything else belongs in a discussion issue before implementation.

---

## 2. Safety Posture & Operational Guardrails

- `DEMO_MODE` stays `true` on `main`. Persistent storage, network broadcasts, or potentially irreversible operations belong in feature branches clearly marked as experimental.
- CLI additions must default to read-only or reversible actions and clearly label destructive commands. Every new command must explain its safety model in-line and in docs.
- Consensus-related tooling (e.g., `consensus_test`) must remain deterministic, self-contained, and runnable without prior setup. These commands are the quick health checks that contributors run before committing.
- Secrets, keys, or environment-specific configs are never committed. Use `.gitignore` and local environment variables; document setup steps separately.
- Any dependency bump or new library requires a security note explaining attack-surface changes and how equality invariants remain protected.

---

## 3. Contribution Workflow & Checklist

1. **Scope Alignment**  
   - Confirm the change preserves the five core invariants above.  
   - Document how the contribution benefits equality, safety, or accessibility.
2. **Implementation Standards**  
   - Follow Julia idioms and keep modules lightweight.  
   - Avoid reformatting unrelated sections; keep diffs focused.  
   - Surface assumptions explicitly inside the PR description and code comments.
3. **Validation Commands (run locally before pushing)**  
   ```bash
   julia --startup-file=no --project -e 'using Test; include("files/tests/hash_block_test.jl"); include("files/tests/node_test.jl"); include("files/tests/consensus_test.jl")'
   ```
   - For CLI-facing work: `julia aequchain.jl cli` and run `consensus_test`, `demo`, or other relevant flows to prove the experience stays safe and deterministic.
4. **Documentation Expectations**  
   - Update or create guides in `files/docs/**` when behavior changes.  
   - Note demo vs. production implications explicitly. If the change affects possible productionization, add a TODO section describing required audits.
5. **Commit Hygiene**  
   - Use present-tense, scoped messages (`module: summary`).  
   - Avoid bundling unrelated features.  
   - Reference issues or roadmap items when applicable to keep narrative cohesion.

---

## 4. Review & Merge Protocol

- **Self-Review First:** Ensure diffs read cleanly, comments are resolved, and validation output is attached to the PR description. Screenshots or CLI transcripts (like `consensus_test`) are encouraged.
- **Equality/Safety Gate:** Reviewers must explicitly state how the change preserves equality and demo safety. PRs without this acknowledgment do not merge.
- **Testing Gate:** A PR cannot merge unless the quick test suite above passes (CI will mirror the single-command invocation). For broader changes, request targeted benchmarks or adversarial tests as needed.
- **Doc Gate:** If behavior changed and documentation didnt, the reviewer blocks the merge until docs match reality.

---

## 5. Branching & Release Strategy

- `main`: Always safe, ephemeral demo-quality. No persistence, no guarded features.  
- `staging/*`: Longer-running experiments; must feature prominent warnings and be documented before public mention.  
- `production/*`: Reserved for future audited, persistent deployments. These branches require formal approval, security review, and sign-off from maintainers responsible for equality guarantees.

Any contributor, regardless of experience, should feel confident pulling `main` and experimenting. Releases aiming for durability must fork from a stable point and undergo additional audits before public availability.

---

## 6. Security & Audit Trail

- Maintain a running ledger (issue or doc) of consensus, treasury, or identity changes. Every adjustment should be traceable.
- When introducing new cryptographic primitives or consensus adjustments, include: design rationale, threat model notes, and manual test vectors.
- Encourage external audits but never rely solely on them. Peer review inside the project remains mandatory.
- Log the outcomes of `consensus_test` (and future quick checks) in PR discussion threads so results remain public and reproducible.

---

## 7. Collaboration Culture

- Communicate intent: start PRs or issues with the user problem, then the solution.
- Respect knowledge diversity: avoid gatekeeping; explain decisions so new collaborators can learn and help.
- Surface risks early: propose mitigation strategies alongside the change.
- Champion accessibility: every tool or doc should guide readers from zero knowledge to practical execution.

---

## 8. Rapid Reference Checklist

Before merging or approving any change, confirm:

- [ ] Equality invariant explicitly preserved or enhanced.
- [ ] `main` behavior remains ephemeral and safe to run.
- [ ] All quick tests (hash, node, consensus) pass locally.
- [ ] New or changed commands documented with safety notes.
- [ ] Docs updated; demo vs production implications clear.
- [ ] Security considerations captured (threats, mitigations, follow-ups).

Keeping this checklist in pull request templates or review comments reinforces the culture of precision and safety.

---

By adhering to this charter, every GitHub agent, maintainer, and collaborator keeps aequchain aligned with its revolutionary promise: mathematically unbreakable equality, transparent stewardship, and a clear path toward free living for every participant.
