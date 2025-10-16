# **aequchain**

## *Universal Equidistributed Blockchain*
[![Julia](https://img.shields.io/badge/Julia-1.8+-blue.svg)](https://julialang.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Economy](https://img.shields.io/badge/Economy-100%25_Equal-purple.svg)](#)
[![Precision](https://img.shields.io/badge/Precision-Exact_Mathematics-green.svg)](#)
[![AI-Assisted](https://img.shields.io/badge/AI_Assisted-Built_with_AI-blue.svg)](#)

## Overview

https://equied.zapier.app

**aequchain** is a revelation in the implementation of a **Universal Equidistributed Blockchain** that enables multiple nations, multiple business networks, and their own currencies to coexist on a single blockchain while maintaining **100% financial equality** for every member. It scales from local cooperatives to full global currency coverage, all while keeping participation free for real people. The project deliberately steers communities toward a **living-for-free reality**—see [`files/docs/vision/free-living.md`](files/docs/vision/free-living.md) for the technical pathway from equality to complete freedom from monetary dependence.

**status:** *safe for testing* testable testnet. demo's and examples. ephemeral. non-persisting. [nothing writes to blockchain permanently, close or reset and everything is cleared]

[should be fully audited, tested, and hardened *before put into production use*]

> #### Testnet status (October 2025)
> - There is **no public or hosted aequchain testnet** at present. Everything runs locally inside the demo CLI and the in-memory `node_*` commands.
> - Launching `julia aequchain.jl cli` creates an ephemeral sandbox. Running `node_init`, `node_register`, `node_pay`, `consensus_test`, or `equality_check` operates entirely in memory and discards state on exit.
> - All balances, coins, and certificates are simulation artifacts with **zero monetary value**. They exist for research and education only.
> - Deploying beyond this demo requires jurisdiction-specific compliance (KYC/AML, licensing, taxation, consumer protection). Engage qualified legal counsel before operating any real network.
> - Contributors must keep the repository in **DEMO_MODE** (see `GITHUB_AGENTS.md`) and avoid connecting it to persistent ledgers, customer data, or regulated financial flows until a full audit is complete.

## Notices

- 2025-10-01: CLI behaviour: when running `equality_check --format plain` from the interactive
    demo CLI (`julia aequchain.jl cli`) the report will now pause and prompt `Press Enter to continue...`
    before returning to the landing screen. This aligns `equality_check` with the UX of other interactive
    commands. Machine modes (`--format json` and `--output <file>`) remain non-blocking and suitable for
    scripting and automation.

## **≡**  Revolutionary Capabilities

[should be security audited, have persistent storage, and undergo formal testing *before put into production use*]

**aequchain** achieves what was previously thought impossible:
- **Multi-Nation & Multi-Network Support**: Hosts multiple countries and business networks with their own denominations
- **Global Exchange Rates**: Maintains automatic global exchange rates via currency pegs
- **Perfect Financial Equality**: Guarantees 100% equal value for every member, regardless of network affiliations
- **Internal Free Trade**: Enables transactions where money circulates but balances remain exactly equal
- **Poverty Elimination**: Provides a foundation for universal base income systems

## **=** Key Breakthrough Features

### Global Economic Integration

- **Multiple National Currencies**: Each nation maintains its currency while participating in global equality
- **Business Network Support**: Corporations can operate their own networks with internal currencies
- **Seamless Cross-Network Value**: Members can belong to multiple networks while maintaining equal value
- **Automatic Peg Management**: Exchange rates are mathematically maintained across all networks

### **∼** Use Cases

- **International Commerce**: Trade between nations with different currencies while maintaining equality
- **Multi-National Organizations**: Businesses operating across multiple countries/currencies
- **Global Cooperatives**: Equal ownership regardless of local currency or economic conditions
- **Cross-Border Collaboration**: Projects spanning multiple nations with automatic currency handling
- **Economic Integration**: Seamless integration of different national economic systems

This implementation demonstrates how multiple sovereign networks with independent denominations can coexist while guaranteeing absolute equality for all participants globally.

### Mathematical Precision & Safety

[should be formally verified and penetration tested *before put into production use*]

- **Exact Monetary Precision**: Uses `Rational{BigInt}` for perfect arithmetic without floating-point errors
- **100% Equality Guarantee**: Every member's value = Total Treasury / Total Members (always equal)
- **30-Day Safety Limits**: Prevents treasury depletion with intelligent spending controls
- **Non-Transferable Member Coins**: Maintains perfect equality through automatic rebalancing

### Advanced Economic Mechanisms

[should have full automated test coverage and continuous integration *before put into production use*]

- **Enterprise Contribution System**: Businesses can set contribution rates (0-5%) for operational costs
- **Pledge Funding**: Both member and business pledges for special funding needs
- **Recurring Business Pledges**: Automated funding for ongoing business operations
- **Production Chain Tracking**: Foundation for internalized production leading to free products

## **∝** The Potential for Complete Economic Freedom
*possibilities this system can facilitate and on blockchain*

### Natural Market Signals & Self-Optimization
**aequchain** creates an economic system that naturally evolves toward complete self-sufficiency through intelligent market signaling:
```julia
function calculate_internalization_priority()
    # What external costs are we consistently covering?
    high_pledge_areas = find_high_demand_pledges()
    # These become the NEXT internalization targets
    return high_pledge_areas
end
```

The system can automatically identifies which external dependencies are costing the most (through pledge tracking) and creates natural incentives to internalize them. This creates a **virtuous cycle** where the economy becomes increasingly efficient over time.

### The "Living for Free" Progression

The dedicated roadmap in [`files/docs/vision/free-living.md`](files/docs/vision/free-living.md) outlines how the protocol operationalizes this outcome. The summary below shows the high-level logic the codebase aims to automate:
```julia
function can_live_for_free(member_id::String)
    # Basic needs covered by internalized chains
    food_chain = get_food_production_chain()
    housing_chain = get_housing_chain()
    energy_chain = get_energy_chain()

    basic_needs_covered = (
        is_fully_internalized(food_chain) &&
        is_fully_internalized(housing_chain) &&
        is_fully_internalized(energy_chain)
    )

    # Remaining costs covered by system mechanisms
    remaining_costs_covered = (
        get_enterprise_contribution_cover() +
        get_pledge_cover() >=
        get_external_costs()
    )

    return basic_needs_covered && remaining_costs_covered
end
```

### Automatic Economic Optimization

The system continuously improves itself without central planning:
```julia
function optimize_toward_complete_free_living()
    while !is_everything_free()
        # Find highest external cost being covered by pledges
        next_target = find_most_expensive_external_dependency()

        # System naturally incentivizes internalizing it
        create_internalization_incentive(next_target)

        # As it internalizes, pledges decrease, system becomes more efficient
        reduce_pledge_requirements(next_target)
    end
end
```

This creates an **economic evolution engine** that starts working immediately with real-world constraints and naturally progresses toward complete internalization and free access to goods and services.

## **≡** Purpose & Vision

**aequchain** demonstrates a new economic paradigm where:
- Financial equality is mathematically guaranteed
- Nations and businesses cooperate rather than compete
- Internal transactions become free (money circulates but equality persists)
- Poverty is eliminated through universal equidistribution
- Economic activity continues without financial stress
- **The system self-optimizes** toward increasing efficiency and freedom

### Broader Social Benefits

- **Transparency**: Complete blockchain visibility prevents financial corruption
- **Poverty Alleviation**: Every member receives equal economic participation
- **Crime Reduction**: Eliminates financial necessity as crime motivator
- **Universal Access**: Ensures availability of essentials: food, housing, healthcare, education
- **Business Efficiency**: Reduces operational costs by eliminating internal financial transactions
- **Natural Optimization**: Market signals guide efficient resource allocation without central planning

## **≡** How It Works: The Equality Engine

### Core Principle:
```
Member_Value = Total_Treasury / Total_Members
```

This simple equation guarantees perfect equality. When members transact, money rebalances automatically to maintain this equality, making internal transactions effectively free.

### Multi-Network Magic:

```julia
# Each network displays the same equal value in its denomination
USD_Value = Member_Value * 1.0      # US Dollar network
ZAR_Value = Member_Value * 17.35    # South African Rand network
EUR_Value = Member_Value * 0.85     # Euro network
```

## **≈** Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/**aequchain**/**aequchain**.git
   cd **aequchain**
   ```

2. **Run the software:**
    ```bash
    # Run the interactive CLI (recommended):
    julia **aequchain**.jl

    # Run the automated demo instead:
    julia **aequchain**.jl demo
    ```

    ```bash
    # Launch the CLI explicitly
    julia **aequchain**.jl cli
    ```

3. **Explore the economic revolution:**
    - Initialize the treasury (`init_treasury`)
    - Join members with equal deposits (`join_member`)
    - Create national and business networks (`create_network`)
    - Establish businesses with contribution systems (`create_business`)
    - Experience internal free trade (transfers that maintain equality)

### **δ** Ephemeral Testnet Walkthrough (No Persistence)

[should have secure, environment-specific configuration *before put into deployed Testnet*]

Everything in demo mode lives only in memory—when you exit the CLI, the blockchain vanishes. Try the in-memory consensus pipeline in about a minute:
```bash
julia --startup-file=no **aequchain**.jl cli
# inside the CLI
node_init 16 11           # start a fresh node (committee of 16, threshold 11)
node_register alice 1000  # add a sender with integer balance
node_register bob 800     # add a recipient
node_pay alice bob 125    # produces send+receive blocks with quorum certs
node_status               # shows latency, throughput, and memory headroom
```

*Tips*

- `node_status` lists every registered account (up to 10) with balances plus live metrics (latency, throughput, memory projections at 4 GB and 8 GB).
- `node_metrics [mem_gb]` provides a longer report and lets you add a custom memory target (for example `node_metrics 12`).
- `node_blocks` and `node_qc` print the most recent canonical block JSON and quorum certificates if you need to inspect hashes.
- Forget to register an account? `node_pay` now hints which ID is missing; just run `node_register <id> [balance]` and retry.
- Want to verify the consensus primitives quickly? From the CLI prompt run:

    ```text
    consensus_test
    ```

    This deterministic self-test exercises committee selection, quorum aggregation, duplicate vote handling, insufficient vote rejection, and conflicting-hash detection, printing a ✅/❌ summary while keeping the environment entirely ephemeral.

- Need to confirm the treasury equality invariants? Inside the CLI run:

    ```text
    equality_check
    ```

    The command inspects the live in-memory ledger and validates that treasury math, member registries, network memberships, 30-day spending, and business/pledge references all respect the global equality contract. Add `--format=json` for machine-readable output, and combine with `--output equality-report.json` to archive the structured payload for compliance reviews.

See [`files/docs/guides/testnet-cli.md`](files/docs/guides/testnet-cli.md) for a complete step-by-step guide, troubleshooting tips, and advice on recording experiment metrics.

### 🔁 Pre-push safety sweep

1. `./bin/quickcheck.sh` — runs the deterministic hash, node, and consensus test suites in one pass.
2. `consensus_test` — within the CLI, double-checks committee rotation and quorum aggregation behavior.
3. `equality_check [--format json] [--output <file>]` — within the CLI, verifies equality invariants and reference integrity; the optional flags let you stream JSON for automation or persist an audit record locally.

> ℹ️ Continuous integration via hosted runners is intentionally omitted to avoid burning GitHub Actions minutes. The quickcheck script keeps the workflow fast, local, and free.

## **≡** Core Architecture

### Global Economic Structures

- `Treasury`: Manages global stablecoins with currency pegging
- `MemberCoin`: Non-transferable coins guaranteeing equal value for all
- `Network`: National or business networks with custom denominations
- `Business`: Enterprises with contribution systems and spending allocations
- `Pledge`: Funding mechanisms for special projects and external costs

### Safety & Governance

- **Immutable 30-Day Limits**: Spending controls protect treasury integrity
- **0-5% Contribution Bounds**: Enterprise contributions have mathematical limits
- **Every Member Validates**: Democratic transaction verification
- **Transparent Blockchain**: All operations are publicly auditable

## **ε** Technical Excellence

- **Julia Language**: High-performance technical computing with mathematical precision
- `Rational{BigInt}`: Exact arithmetic avoiding floating-point errors
- **SHA-256 Hashing**: Secure blockchain integrity [should ensure all cryptographic operations are secure, keys are managed safely, and consensus is robust before put into production use]
- **Lightweight Design**: Efficient enough for global scale deployment
- **Demo Mode Safe**: No persistence - perfect for experimentation

## **≡** Revolutionary Implications

### For Nations:

- Maintain national currency sovereignty while participating in global equality
- Eliminate poverty through mathematical wealth distribution
- Reduce crime by removing financial desperation
- Improve public services through efficient resource allocation
- Gain automatic economic optimization through natural market signals

### For Businesses:

- Operate with dramatically reduced transactional overhead
- Access global talent pool without currency complications
- Focus on production rather than financial optimization
- Participate in economic systems that value contribution over accumulation
- Receive clear signals for which production chains to internalize next

### For Individuals:

- Guaranteed economic security through equal participation
- Freedom to pursue meaningful work without financial pressure
- Access to essentials regardless of employment status
- Participation in transparent, corruption-resistant systems
- Witness continuous improvement in quality of life as the system optimizes

## **=** Demo Features

The `run_demo()` function demonstrates:

- **Treasury initialization** with founding member
- **Member joining** with automatic equal distribution
- **Multi-network creation** (USD, ZAR examples)
- **Business establishment** with contribution systems
- **Hiring workflow** that adds members to businesses
- **Member & business withdrawals** demonstrating external payments under equality limits
- **Pledge mechanisms** for both personal and business needs
- **Internal free trade** where transactions maintain perfect equality

## **∼** Future Potential & Extensions

### Potential Code Additions Under Consideration:
#### Production Chain Tracking

```julia
# Track when production becomes fully internalized
function is_fully_internalized(production_chain::Vector{String})::Bool
    return all(bus_id in keys(BLOCKCHAIN.businesses) for bus_id in production_chain)
end

# Automatically provide free products when chain is internalized
function provide_free_product(production_chain::Vector{String}, product_id::String)
    if is_fully_internalized(production_chain)
        println("🎁 FREE PRODUCT: $product_id (fully internalized chain)")
    end
end
```

#### Natural Market Signal Detection

```julia
# System automatically identifies optimization opportunities
function find_optimization_priorities()
    high_demand_pledges = filter(p -> p.current_amount > p.target_amount * 0.8,
                                 values(BLOCKCHAIN.pledges))
    return [pledge.purpose for pledge in high_demand_pledges]
end
```

#### Progressive Freedom Achievement

```julia
# Measure progress toward complete economic freedom
function calculate_freedom_progress()
    basic_needs = ["food", "housing", "energy", "healthcare", "education"]
    internalized_count = count(need -> is_need_internalized(need), basic_needs)
    return internalized_count / length(basic_needs) * 100
end
```

These extensions would operationalize the vision of a self-optimizing economic system that naturally progresses toward complete freedom and abundance.

## **∝** Sustainable Resource Management

The ultimate goal requires **Sustainable, Renewable and Recyclable Resource Management** for "infinite freedom". The economic framework provides the foundation, but true long-term sustainability depends on responsible resource stewardship:
- **Renewable Energy**: Transition to 100% sustainable energy sources
- **Circular Economy**: Complete recycling and reuse of materials
- **Sustainable Agriculture**: Regenerative farming practices
- **Resource Conservation**: Efficient use of finite resources
- **Ecosystem Preservation**: Maintaining biodiversity and natural balance

## **≠** Important Notes

- **DEMO_MODE = true**: Currently configured for safe testing without persistence
- **Research Implementation**: Not for production use without proper security implementation
- **Mathematical Proof-of-Concept**: Demonstrates economic principles with exact mathematics
- **Transparency Focus**: All operations are mathematically verifiable

## **=** License

This project is licensed under the MIT License. See the LICENSE file for details.

## **∀** Acknowledgments

- Inspired by principles of universal economic equality
- Built with Julia for mathematical precision and performance
- Conceptual foundations in equitable distribution systems

---

## **∼** Developer Notes

The code examples shown in the "Future Potential" section represent conceptual extensions that could build upon the current solid foundation. The core **aequchain**.jl implementation provides the complete mathematical framework for multi-network equality - these extensions would operationalize the vision of automatic economic optimization and progressive freedom achievement.
The current implementation is feature-complete for demonstrating the revolutionary economic principles. Future extensions would focus on making the self-optimization mechanisms explicit and measurable.

---

****aequchain** represents more than code - it's a mathematical proof that a different economic reality is possible.** One where equality is guaranteed, cooperation replaces competition, financial stress becomes historical, and the system naturally optimizes toward increasing freedom and abundance for all.
*Join the exploration of what becomes possible when everyone has equal economic footing and the market guides us toward collective optimization.*
