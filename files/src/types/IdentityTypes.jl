module IdentityTypes

export IdentityTier, TierLimits, DocumentHash, AnonymousIdentity, DocumentedIdentity
export BusinessIdentity, VouchRecord, LicenseRecord, BiometricBinding

using ..Types: AccountID, Hash

# Identity tier enumeration
@enum IdentityTier begin
    TIER_0_ANONYMOUS = 0
    TIER_1_DOCUMENTED = 1
    TIER_2_BUSINESS = 2
end

# Rate limits per tier (Fibonacci-based values)
struct TierLimits
    tier::IdentityTier
    requests_per_minute::Int
    requests_per_day::Int
    transaction_value_limit::Float64  # % of treasury
    content_upload_mb_per_day::Int
end

# Tier limits configuration
const TIER_LIMITS = Dict(
    TIER_0_ANONYMOUS => TierLimits(TIER_0_ANONYMOUS, 21, 233, 0.001, 5),
    TIER_1_DOCUMENTED => TierLimits(TIER_1_DOCUMENTED, 89, 987, 0.01, 34),
    TIER_2_BUSINESS => TierLimits(TIER_2_BUSINESS, 233, 2584, 0.05, 144),
)

# Document hash record
struct DocumentHash
    doc_type::String  # "national_id", "passport", "drivers_license", "business_registration", "tax_id"
    hash::Hash  # SHA3-512 of document (never store raw document)
    issuer_code::String  # ISO country code or authority identifier
    expiry::Union{Int64,Nothing}  # Unix timestamp, nothing if no expiry
end

# Vouch record for Tier 0 members
struct VouchRecord
    voucher_id::AccountID
    voucher_tier::IdentityTier
    timestamp::Int64
    strength::Float64  # Based on voucher's reputation (0.0 to 1.0)
end

# Biometric binding (device-local only, commitment stored on-chain)
struct BiometricBinding
    device_id::Hash  # Hashed device identifier
    binding_commitment::Hash  # Hash of biometric template hash (double-hashed)
    binding_date::Int64
    last_verified::Int64
end

# License record for businesses
struct LicenseRecord
    license_type::String  # e.g., "operating_license", "health_permit", "professional_license"
    license_hash::Hash
    issuing_authority::String
    valid_from::Int64
    valid_until::Int64
end

# Tier 0: Anonymous/Outlier identity
mutable struct AnonymousIdentity
    account_id::AccountID
    social_vouches::Vector{VouchRecord}
    reputation_score::Float64  # 0.0 to 1.0
    created_at::Int64
    request_history::Vector{Tuple{Int64,String}}  # For rate limiting
end

function AnonymousIdentity(account_id::AccountID)
    AnonymousIdentity(
        account_id,
        VouchRecord[],
        0.0,
        time_ns() ÷ 1_000_000_000,
        Tuple{Int64,String}[]
    )
end

# Tier 1: Documented identity
struct DocumentedIdentity
    account_id::AccountID
    document_hashes::Vector{DocumentHash}
    biometric_binding::Union{BiometricBinding,Nothing}
    verification_timestamp::Int64
    jurisdiction::String  # ISO country code
    created_at::Int64
end

# Tier 2: Business entity
struct BusinessIdentity
    account_id::AccountID
    business_name::String
    registration_hashes::Vector{DocumentHash}
    licenses::Vector{LicenseRecord}
    beneficial_owners::Vector{AccountID}  # Linked member accounts
    jurisdiction::String
    contribution_rate::Float64  # 0.0 to 0.05 (0-5%)
    created_at::Int64
end

# Get tier limits for a specific tier
get_tier_limits(tier::IdentityTier) = TIER_LIMITS[tier]

# Calculate total vouch strength
function calculate_vouch_strength(vouches::Vector{VouchRecord})::Float64
    return sum(v.strength for v in vouches)
end

# Check if Tier 0 meets upgrade requirements
function can_upgrade_to_tier1(identity::AnonymousIdentity)::Bool
    return length(identity.social_vouches) >= 3 &&
           calculate_vouch_strength(identity.social_vouches) >= 2.0
end

end # module
