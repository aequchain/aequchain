module BusinessRegistry

export BusinessStore, register_business!, get_business, list_businesses
export update_contribution_rate!, add_license!, verify_business_status

using ..Types: AccountID, Hash
using ..IdentityTypes

# Business registry system
mutable struct BusinessStore
    businesses::Dict{AccountID,BusinessIdentity}
    by_name::Dict{String,AccountID}  # Name -> AccountID lookup
    by_jurisdiction::Dict{String,Vector{AccountID}}  # Jurisdiction -> businesses
end

function BusinessStore()
    BusinessStore(
        Dict{AccountID,BusinessIdentity}(),
        Dict{String,AccountID}(),
        Dict{String,Vector{AccountID}}()
    )
end

# Register a new business
function register_business!(
    store::BusinessStore,
    business::BusinessIdentity
)::Bool
    # Check if account already registered
    if haskey(store.businesses, business.account_id)
        @warn "Business already registered" account_id=business.account_id
        return false
    end
    
    # Check if business name already taken
    if haskey(store.by_name, business.business_name)
        @error "Business name already taken" name=business.business_name
        return false
    end
    
    # Validate contribution rate (0-5%)
    if business.contribution_rate < 0.0 || business.contribution_rate > 0.05
        @error "Invalid contribution rate" rate=business.contribution_rate
        return false
    end
    
    # Store business
    store.businesses[business.account_id] = business
    store.by_name[business.business_name] = business.account_id
    
    # Index by jurisdiction
    if !haskey(store.by_jurisdiction, business.jurisdiction)
        store.by_jurisdiction[business.jurisdiction] = AccountID[]
    end
    push!(store.by_jurisdiction[business.jurisdiction], business.account_id)
    
    @info "Business registered" account_id=business.account_id name=business.business_name
    return true
end

# Get business by account ID
function get_business(store::BusinessStore, account_id::AccountID)::Union{BusinessIdentity,Nothing}
    return get(store.businesses, account_id, nothing)
end

# Get business by name
function get_business_by_name(store::BusinessStore, name::String)::Union{BusinessIdentity,Nothing}
    account_id = get(store.by_name, name, nothing)
    if account_id === nothing
        return nothing
    end
    return get_business(store, account_id)
end

# List all businesses
function list_businesses(store::BusinessStore)::Vector{BusinessIdentity}
    return collect(values(store.businesses))
end

# List businesses in a jurisdiction
function list_businesses_by_jurisdiction(store::BusinessStore, jurisdiction::String)::Vector{BusinessIdentity}
    account_ids = get(store.by_jurisdiction, jurisdiction, AccountID[])
    businesses = BusinessIdentity[]
    
    for account_id in account_ids
        business = get_business(store, account_id)
        if business !== nothing
            push!(businesses, business)
        end
    end
    
    return businesses
end

# Update business contribution rate
function update_contribution_rate!(
    store::BusinessStore,
    account_id::AccountID,
    new_rate::Float64
)::Bool
    business = get_business(store, account_id)
    if business === nothing
        return false
    end
    
    if new_rate < 0.0 || new_rate > 0.05
        @error "Invalid contribution rate" rate=new_rate
        return false
    end
    
    # Create updated business
    updated = BusinessIdentity(
        business.account_id,
        business.business_name,
        business.registration_hashes,
        business.licenses,
        business.beneficial_owners,
        business.jurisdiction,
        new_rate,
        business.created_at
    )
    
    store.businesses[account_id] = updated
    
    @info "Contribution rate updated" account_id=account_id old=business.contribution_rate new=new_rate
    return true
end

# Add license to business
function add_license!(
    store::BusinessStore,
    account_id::AccountID,
    license::LicenseRecord
)::Bool
    business = get_business(store, account_id)
    if business === nothing
        return false
    end
    
    # Validate license dates
    now = time_ns() ÷ 1_000_000_000
    if license.valid_from > now
        @error "License not yet valid" from=license.valid_from
        return false
    end
    
    if license.valid_until < now
        @error "License already expired" until=license.valid_until
        return false
    end
    
    # Create updated business with new license
    new_licenses = copy(business.licenses)
    push!(new_licenses, license)
    
    updated = BusinessIdentity(
        business.account_id,
        business.business_name,
        business.registration_hashes,
        new_licenses,
        business.beneficial_owners,
        business.jurisdiction,
        business.contribution_rate,
        business.created_at
    )
    
    store.businesses[account_id] = updated
    
    @info "License added" account_id=account_id type=license.license_type
    return true
end

# Verify business has valid status (documents and licenses)
function verify_business_status(store::BusinessStore, account_id::AccountID)::Bool
    business = get_business(store, account_id)
    if business === nothing
        return false
    end
    
    # Check has at least one registration document
    if isempty(business.registration_hashes)
        return false
    end
    
    # Check all licenses are valid (not expired)
    now = time_ns() ÷ 1_000_000_000
    for license in business.licenses
        if license.valid_until < now
            return false  # Expired license
        end
    end
    
    return true
end

# Get total contribution from businesses
function calculate_total_contribution(store::BusinessStore)::Float64
    total = 0.0
    for business in values(store.businesses)
        total += business.contribution_rate
    end
    return total
end

end # module
