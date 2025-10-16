module ContentTypes

export ContentChunk, ContentManifest, NodeContentRegistry, EncryptedContent
export ContentMetadata, ContentAccessControl

using ..Types: AccountID, Hash

# Individual content chunk (256KB max for efficient distribution)
struct ContentChunk
    hash::Hash
    data::Vector{UInt8}
    size::Int64
end

# Content metadata
struct ContentMetadata
    title::String
    description::String
    content_type::String  # MIME type
    tags::Vector{String}
    created_at::Int64
    file_size::Int64
end

# Access control for content
@enum AccessLevel begin
    PUBLIC = 0
    MEMBERS_ONLY = 1
    RESTRICTED = 2  # Specific account list
end

struct ContentAccessControl
    level::AccessLevel
    authorized_accounts::Vector{AccountID}  # Used when level == RESTRICTED
end

# Encrypted content wrapper
struct EncryptedContent
    manifest_hash::Hash
    encryption_type::String  # "none", "aes256", "rsa"
    encrypted_key::Union{Vector{UInt8},Nothing}  # Encrypted symmetric key
    access_control::ContentAccessControl
end

# Content manifest - links all chunks and provides integrity verification
struct ContentManifest
    root_hash::Hash  # Hash of entire content
    chunks::Vector{Hash}  # Ordered list of chunk hashes
    metadata::ContentMetadata
    timestamp::Int64
    publisher::AccountID
    encryption::Union{EncryptedContent,Nothing}
    signature::Vector{UInt8}  # Publisher's signature over manifest
end

function ContentManifest(
    root_hash::Hash,
    chunks::Vector{Hash},
    metadata::ContentMetadata,
    publisher::AccountID
)
    ContentManifest(
        root_hash,
        chunks,
        metadata,
        time_ns() ÷ 1_000_000_000,
        publisher,
        nothing,
        UInt8[]  # Signature added after construction
    )
end

# Node's content registry - tracks what content this node hosts
mutable struct NodeContentRegistry
    node_id::AccountID
    hosted::Set{Hash}  # Set of content hashes this node hosts
    served_count::Dict{Hash,Int64}  # How many times each content was served
    bandwidth_contributed::Int64  # Total bytes served
    reputation_score::Float64  # Based on uptime and service quality
    last_updated::Int64
end

function NodeContentRegistry(node_id::AccountID)
    NodeContentRegistry(
        node_id,
        Set{Hash}(),
        Dict{Hash,Int64}(),
        0,
        1.0,
        time_ns() ÷ 1_000_000_000
    )
end

# Add content to node's hosted set
function add_hosted_content!(registry::NodeContentRegistry, content_hash::Hash)
    push!(registry.hosted, content_hash)
    registry.served_count[content_hash] = 0
    registry.last_updated = time_ns() ÷ 1_000_000_000
end

# Record that content was served
function record_served!(registry::NodeContentRegistry, content_hash::Hash, bytes::Int64)
    if haskey(registry.served_count, content_hash)
        registry.served_count[content_hash] += 1
        registry.bandwidth_contributed += bytes
        registry.last_updated = time_ns() ÷ 1_000_000_000
    end
end

# Calculate reputation based on service
function update_reputation!(registry::NodeContentRegistry)
    total_served = sum(values(registry.served_count))
    content_diversity = length(registry.hosted)
    
    # Simple reputation formula (can be enhanced)
    base_score = min(1.0, (total_served / 1000.0) * 0.5 + (content_diversity / 100.0) * 0.5)
    registry.reputation_score = base_score
end

end # module
