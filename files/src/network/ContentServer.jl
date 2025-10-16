module ContentServer

export ContentStore, chunk_content, store_content!, retrieve_content, publish_to_aequnet!
export verify_content_integrity

using SHA
using ..Types: AccountID, Hash
using ..ContentTypes
using ..ContentDHT

# Content chunking parameters (Fibonacci-based)
const CHUNK_SIZE = 262144  # 256KB (2^18, Fibonacci-adjacent)
const MAX_CONTENT_SIZE = 10485760  # 10MB for demo mode

# Content storage
mutable struct ContentStore
    chunks::Dict{Hash,ContentChunk}
    manifests::Dict{Hash,ContentManifest}
    local_registry::NodeContentRegistry
    dht::DHT
end

function ContentStore(node_id::AccountID, dht::DHT)
    ContentStore(
        Dict{Hash,ContentChunk}(),
        Dict{Hash,ContentManifest}(),
        NodeContentRegistry(node_id),
        dht
    )
end

# Chunk content into fixed-size pieces
function chunk_content(data::Vector{UInt8})::Vector{ContentChunk}
    if length(data) > MAX_CONTENT_SIZE
        @error "Content too large" size=length(data) max=MAX_CONTENT_SIZE
        return ContentChunk[]
    end
    
    chunks = ContentChunk[]
    offset = 1
    
    while offset <= length(data)
        chunk_end = min(offset + CHUNK_SIZE - 1, length(data))
        chunk_data = data[offset:chunk_end]
        
        # Hash chunk using SHA256 (Blake3 would be better but using SHA for simplicity)
        chunk_hash = bytes2hex(sha256(chunk_data))
        
        chunk = ContentChunk(chunk_hash, chunk_data, length(chunk_data))
        push!(chunks, chunk)
        
        offset = chunk_end + 1
    end
    
    @info "Content chunked" total_size=length(data) num_chunks=length(chunks)
    return chunks
end

# Reassemble content from chunks
function reassemble_content(chunks::Vector{ContentChunk})::Vector{UInt8}
    result = UInt8[]
    for chunk in chunks
        append!(result, chunk.data)
    end
    return result
end

# Create content manifest
function create_manifest(
    chunks::Vector{ContentChunk},
    metadata::ContentMetadata,
    publisher::AccountID
)::ContentManifest
    chunk_hashes = [chunk.hash for chunk in chunks]
    
    # Calculate root hash (hash of all chunk hashes concatenated)
    combined = join(chunk_hashes)
    root_hash = bytes2hex(sha256(Vector{UInt8}(combined)))
    
    manifest = ContentManifest(
        root_hash,
        chunk_hashes,
        metadata,
        publisher
    )
    
    return manifest
end

# Store content locally and announce to DHT
function store_content!(
    store::ContentStore,
    content::Vector{UInt8},
    metadata::ContentMetadata,
    publisher::AccountID
)::Union{ContentManifest,Nothing}
    # Chunk content
    chunks = chunk_content(content)
    if isempty(chunks)
        return nothing
    end
    
    # Store chunks locally
    for chunk in chunks
        store.chunks[chunk.hash] = chunk
        add_hosted_content!(store.local_registry, chunk.hash)
    end
    
    # Create manifest
    manifest = create_manifest(chunks, metadata, publisher)
    store.manifests[manifest.root_hash] = manifest
    
    # Announce to DHT
    announce_content!(store.dht, store.local_registry.node_id, manifest.root_hash)
    
    # Also announce individual chunks (for better distribution)
    for chunk in chunks
        announce_content!(store.dht, store.local_registry.node_id, chunk.hash)
    end
    
    @info "Content stored and announced" root_hash=manifest.root_hash chunks=length(chunks)
    return manifest
end

# Retrieve content from local storage or DHT
function retrieve_content(
    store::ContentStore,
    content_hash::Hash
)::Union{Vector{UInt8},Nothing}
    # Check if we have the manifest
    if !haskey(store.manifests, content_hash)
        # Try to fetch from DHT
        nodes = find_content(store.dht, content_hash)
        if isempty(nodes)
            @warn "Content not found" hash=content_hash
            return nothing
        end
        
        # In real implementation, would fetch from remote node
        # For demo, assume we can't fetch
        @warn "Content on remote nodes (fetching not implemented in demo)" hash=content_hash
        return nothing
    end
    
    manifest = store.manifests[content_hash]
    
    # Retrieve all chunks
    chunks = ContentChunk[]
    for chunk_hash in manifest.chunks
        if !haskey(store.chunks, chunk_hash)
            @error "Missing chunk" chunk_hash=chunk_hash
            return nothing
        end
        push!(chunks, store.chunks[chunk_hash])
    end
    
    # Reassemble content
    content = reassemble_content(chunks)
    
    # Record retrieval
    record_served!(store.local_registry, content_hash, length(content))
    
    return content
end

# Verify content integrity against manifest
function verify_content_integrity(
    content::Vector{UInt8},
    manifest::ContentManifest
)::Bool
    # Rechunk and verify
    chunks = chunk_content(content)
    
    if length(chunks) != length(manifest.chunks)
        @warn "Chunk count mismatch"
        return false
    end
    
    for (i, chunk) in enumerate(chunks)
        if chunk.hash != manifest.chunks[i]
            @warn "Chunk hash mismatch" index=i
            return false
        end
    end
    
    # Verify root hash
    chunk_hashes = [chunk.hash for chunk in chunks]
    combined = join(chunk_hashes)
    computed_root = bytes2hex(sha256(Vector{UInt8}(combined)))
    
    if computed_root != manifest.root_hash
        @warn "Root hash mismatch"
        return false
    end
    
    return true
end

# Publish content to AequNet (full workflow)
function publish_to_aequnet!(
    store::ContentStore,
    content::Vector{UInt8},
    title::String,
    description::String,
    content_type::String,
    tags::Vector{String},
    publisher::AccountID
)::Union{ContentManifest,Nothing}
    metadata = ContentMetadata(
        title,
        description,
        content_type,
        tags,
        time_ns() ÷ 1_000_000_000,
        length(content)
    )
    
    manifest = store_content!(store, content, metadata, publisher)
    
    if manifest !== nothing
        @info "Published to AequNet" title=title size=length(content) hash=manifest.root_hash
    end
    
    return manifest
end

# Get content metadata
function get_content_metadata(
    store::ContentStore,
    content_hash::Hash
)::Union{ContentMetadata,Nothing}
    manifest = get(store.manifests, content_hash, nothing)
    if manifest === nothing
        return nothing
    end
    return manifest.metadata
end

# List all locally hosted content
function list_local_content(store::ContentStore)::Vector{ContentManifest}
    return collect(values(store.manifests))
end

end # module
