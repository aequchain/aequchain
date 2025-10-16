module APITypes

export APIRequest, APIResponse, APIError, ErrorCode
export AccountCreateRequest, TransactionRequest, PledgeRequest
export JobRequest, EnterpriseRequest, ContentPublishRequest

using ..Types: AccountID, Hash

# Error codes for API responses
@enum ErrorCode begin
    SUCCESS = 0
    INVALID_REQUEST = 400
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404
    RATE_LIMITED = 429
    INTERNAL_ERROR = 500
end

# Generic API error
struct APIError
    code::ErrorCode
    message::String
    details::Union{Dict{String,Any},Nothing}
end

# Generic API response wrapper
struct APIResponse
    success::Bool
    data::Union{Dict{String,Any},Nothing}
    error::Union{APIError,Nothing}
    timestamp::Int64
end

function APIResponse(success::Bool, data::Union{Dict{String,Any},Nothing}=nothing)
    APIResponse(success, data, nothing, time_ns() ÷ 1_000_000_000)
end

function APIResponse(error::APIError)
    APIResponse(false, nothing, error, time_ns() ÷ 1_000_000_000)
end

# Account creation request
struct AccountCreateRequest
    tier::Int  # 0, 1, or 2
    name::String
    jurisdiction::String
    document_hashes::Vector{String}  # Empty for Tier 0
    voucher_ids::Vector{String}  # For Tier 0
end

# Transaction request
struct TransactionRequest
    from::AccountID
    to::AccountID
    amount::Float64
    memo::Union{String,Nothing}
end

# Pledge creation request
struct PledgeRequest
    creator::AccountID
    title::String
    description::String
    amount::Float64
    category::String
    recurring::Bool
    interval_days::Union{Int,Nothing}
end

# Job posting request
struct JobRequest
    creator::AccountID
    title::String
    description::String
    skills_required::Vector{String}
    location::String
    compensation::Union{Float64,Nothing}
end

# Enterprise registration request
struct EnterpriseRequest
    owner::AccountID
    business_name::String
    contribution_rate::Float64  # 0.0 to 0.05
    registration_hashes::Vector{String}
    licenses::Vector{Dict{String,String}}
end

# Content publish request
struct ContentPublishRequest
    publisher::AccountID
    content::Vector{UInt8}
    title::String
    description::String
    content_type::String
    tags::Vector{String}
    access_level::Int  # 0=public, 1=members, 2=restricted
    authorized_accounts::Vector{AccountID}
    encryption_type::String  # "none", "aes256"
end

end # module
