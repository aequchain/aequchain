module IdentityTiers

export IdentityRegistry, register_anonymous!, register_documented!, register_business!
export add_vouch!, check_tier_limits, get_identity_tier, upgrade_to_tier1!

using ..Types: AccountID, Hash
using ..IdentityTypes

# Global identity registry
mutable struct IdentityRegistry
    anonymous::Dict{AccountID,AnonymousIdentity}
    documented::Dict{AccountID,DocumentedIdentity}
    businesses::Dict{AccountID,BusinessIdentity}
    tier_map::Dict{AccountID,IdentityTier}
end

function IdentityRegistry()
    IdentityRegistry(
        Dict{AccountID,AnonymousIdentity}(),
        Dict{AccountID,DocumentedIdentity}(),
        Dict{AccountID,BusinessIdentity}(),
        Dict{AccountID,IdentityTier}()
    )
end

# Register anonymous (Tier 0) identity
function register_anonymous!(registry::IdentityRegistry, account_id::AccountID)::Bool
    if haskey(registry.tier_map, account_id)
        return false  # Already registered
    end
    
    identity = AnonymousIdentity(account_id)
    registry.anonymous[account_id] = identity
    registry.tier_map[account_id] = TIER_0_ANONYMOUS
    
    @info "Registered anonymous identity" account_id=account_id
    return true
end

# Register documented (Tier 1) identity
function register_documented!(
    registry::IdentityRegistry,
    account_id::AccountID,
    document_hashes::Vector{DocumentHash},
    jurisdiction::String,
    biometric_binding::Union{BiometricBinding,Nothing}=nothing
)::Bool
    if haskey(registry.tier_map, account_id) && registry.tier_map[account_id] != TIER_0_ANONYMOUS
        return false  # Can only upgrade from Tier 0 or register new
    end
    
    # Remove from anonymous if upgrading
    if haskey(registry.anonymous, account_id)
        delete!(registry.anonymous, account_id)
    end
    
    identity = DocumentedIdentity(
        account_id,
        document_hashes,
        biometric_binding,
        time_ns() ÷ 1_000_000_000,
        jurisdiction,
        time_ns() ÷ 1_000_000_000
    )
    
    registry.documented[account_id] = identity
    registry.tier_map[account_id] = TIER_1_DOCUMENTED
    
    @info "Registered documented identity" account_id=account_id jurisdiction=jurisdiction
    return true
end

# Register business (Tier 2) identity
function register_business!(
    registry::IdentityRegistry,
    account_id::AccountID,
    business_name::String,
    registration_hashes::Vector{DocumentHash},
    licenses::Vector{LicenseRecord},
    beneficial_owners::Vector{AccountID},
    jurisdiction::String,
    contribution_rate::Float64
)::Bool
    if haskey(registry.tier_map, account_id)
        return false  # Cannot upgrade existing account to business
    end
    
    if contribution_rate < 0.0 || contribution_rate > 0.05
        @error "Invalid contribution rate" rate=contribution_rate
        return false
    end
    
    identity = BusinessIdentity(
        account_id,
        business_name,
        registration_hashes,
        licenses,
        beneficial_owners,
        jurisdiction,
        contribution_rate,
        time_ns() ÷ 1_000_000_000
    )
    
    registry.businesses[account_id] = identity
    registry.tier_map[account_id] = TIER_2_BUSINESS
    
    @info "Registered business identity" account_id=account_id business=business_name
    return true
end

# Add vouch to Tier 0 identity
function add_vouch!(
    registry::IdentityRegistry,
    target_id::AccountID,
    voucher_id::AccountID
)::Bool
    # Check target is Tier 0
    if !haskey(registry.anonymous, target_id)
        @warn "Target is not Tier 0" target_id=target_id
        return false
    end
    
    # Check voucher exists and has appropriate tier
    voucher_tier = get(registry.tier_map, voucher_id, nothing)
    if voucher_tier === nothing || voucher_tier == TIER_0_ANONYMOUS
        @warn "Voucher not eligible" voucher_id=voucher_id tier=voucher_tier
        return false
    end
    
    # Calculate vouch strength based on voucher tier
    strength = voucher_tier == TIER_1_DOCUMENTED ? 0.8 : 1.0
    
    vouch = VouchRecord(
        voucher_id,
        voucher_tier,
        time_ns() ÷ 1_000_000_000,
        strength
    )
    
    identity = registry.anonymous[target_id]
    push!(identity.social_vouches, vouch)
    identity.reputation_score = min(1.0, calculate_vouch_strength(identity.social_vouches) / 3.0)
    
    @info "Vouch added" target_id=target_id voucher_id=voucher_id strength=strength
    return true
end

# Upgrade Tier 0 to Tier 1 (if eligible)
function upgrade_to_tier1!(
    registry::IdentityRegistry,
    account_id::AccountID,
    document_hashes::Vector{DocumentHash},
    jurisdiction::String
)::Bool
    if !haskey(registry.anonymous, account_id)
        return false
    end
    
    identity = registry.anonymous[account_id]
    if !can_upgrade_to_tier1(identity)
        @warn "Insufficient vouches for upgrade" account_id=account_id vouches=length(identity.social_vouches)
        return false
    end
    
    return register_documented!(registry, account_id, document_hashes, jurisdiction)
end

# Get identity tier
function get_identity_tier(registry::IdentityRegistry, account_id::AccountID)::Union{IdentityTier,Nothing}
    return get(registry.tier_map, account_id, nothing)
end

# Check if action is within tier limits
function check_tier_limits(
    registry::IdentityRegistry,
    account_id::AccountID,
    action_type::String
)::Bool
    tier = get_identity_tier(registry, account_id)
    if tier === nothing
        return false
    end
    
    limits = get_tier_limits(tier)
    
    # Check rate limits based on tier
    if tier == TIER_0_ANONYMOUS
        identity = registry.anonymous[account_id]
        now = time_ns() ÷ 1_000_000_000
        
        # Count recent requests (last minute and last day)
        minute_ago = now - 60
        day_ago = now - 86400
        
        minute_count = count(t -> t[1] >= minute_ago, identity.request_history)
        day_count = count(t -> t[1] >= day_ago, identity.request_history)
        
        if minute_count >= limits.requests_per_minute
            @warn "Rate limit exceeded (minute)" account_id=account_id count=minute_count
            return false
        end
        
        if day_count >= limits.requests_per_day
            @warn "Rate limit exceeded (day)" account_id=account_id count=day_count
            return false
        end
        
        # Record this request
        push!(identity.request_history, (now, action_type))
        
        # Clean old history (keep last 24 hours + 5 minutes)
        filter!(t -> t[1] >= day_ago - 300, identity.request_history)
    end
    
    return true
end

end # module
