module SocialVouching

export VouchingSystem, vouch_for!, get_vouches, calculate_trust_score
export is_vouch_eligible, validate_vouch_strength

using ..Types: AccountID
using ..IdentityTypes

# Vouching system state
mutable struct VouchingSystem
    vouch_graph::Dict{AccountID,Set{AccountID}}  # who vouched for whom
    reverse_graph::Dict{AccountID,Set{AccountID}}  # who this account has vouched for
    vouch_limits::Dict{AccountID,Int}  # remaining vouches per day
    last_reset::Dict{AccountID,Int64}  # last time vouch counter reset
end

function VouchingSystem()
    VouchingSystem(
        Dict{AccountID,Set{AccountID}}(),
        Dict{AccountID,Set{AccountID}}(),
        Dict{AccountID,Int}(),
        Dict{AccountID,Int64}()
    )
end

# Check if voucher is eligible to vouch
function is_vouch_eligible(
    system::VouchingSystem,
    voucher_id::AccountID,
    voucher_tier::IdentityTier
)::Bool
    # Only Tier 1 and Tier 2 can vouch
    if voucher_tier == TIER_0_ANONYMOUS
        return false
    end
    
    # Check daily vouch limit (Fibonacci: 3 per day)
    now = time_ns() ÷ 1_000_000_000
    day_start = now - (now % 86400)
    
    if haskey(system.last_reset, voucher_id)
        if system.last_reset[voucher_id] < day_start
            # Reset counter for new day
            system.vouch_limits[voucher_id] = 3
            system.last_reset[voucher_id] = day_start
        end
    else
        # First vouch
        system.vouch_limits[voucher_id] = 3
        system.last_reset[voucher_id] = day_start
    end
    
    remaining = get(system.vouch_limits, voucher_id, 3)
    return remaining > 0
end

# Record a vouch in the system
function vouch_for!(
    system::VouchingSystem,
    voucher_id::AccountID,
    target_id::AccountID
)::Bool
    # Check if already vouched
    if haskey(system.vouch_graph, target_id) && voucher_id in system.vouch_graph[target_id]
        @warn "Already vouched" voucher_id=voucher_id target_id=target_id
        return false
    end
    
    # Decrement vouch limit
    if haskey(system.vouch_limits, voucher_id)
        if system.vouch_limits[voucher_id] <= 0
            @warn "Vouch limit exceeded" voucher_id=voucher_id
            return false
        end
        system.vouch_limits[voucher_id] -= 1
    end
    
    # Record vouch
    if !haskey(system.vouch_graph, target_id)
        system.vouch_graph[target_id] = Set{AccountID}()
    end
    push!(system.vouch_graph[target_id], voucher_id)
    
    if !haskey(system.reverse_graph, voucher_id)
        system.reverse_graph[voucher_id] = Set{AccountID}()
    end
    push!(system.reverse_graph[voucher_id], target_id)
    
    @info "Vouch recorded" voucher_id=voucher_id target_id=target_id
    return true
end

# Get all vouchers for an account
function get_vouches(system::VouchingSystem, account_id::AccountID)::Vector{AccountID}
    vouchers = get(system.vouch_graph, account_id, Set{AccountID}())
    return collect(vouchers)
end

# Calculate trust score based on vouch network
function calculate_trust_score(
    system::VouchingSystem,
    account_id::AccountID,
    tier_map::Dict{AccountID,IdentityTier}
)::Float64
    vouchers = get_vouches(system, account_id)
    
    if isempty(vouchers)
        return 0.0
    end
    
    # Weight vouches by voucher tier
    total_weight = 0.0
    for voucher in vouchers
        voucher_tier = get(tier_map, voucher, TIER_0_ANONYMOUS)
        weight = voucher_tier == TIER_1_DOCUMENTED ? 0.8 : 1.0
        total_weight += weight
    end
    
    # Normalize to 0-1 range (3 vouches = 1.0)
    return min(1.0, total_weight / 3.0)
end

# Validate vouch strength for tier upgrade
function validate_vouch_strength(
    system::VouchingSystem,
    account_id::AccountID,
    tier_map::Dict{AccountID,IdentityTier}
)::Bool
    trust_score = calculate_trust_score(system, account_id, tier_map)
    vouch_count = length(get_vouches(system, account_id))
    
    # Need at least 3 vouches with total strength >= 2.0
    return vouch_count >= 3 && trust_score >= (2.0 / 3.0)
end

end # module
