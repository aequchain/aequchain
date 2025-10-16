module ContentDHT

export DHTNode, DHT, add_node!, remove_node!, store_content!, find_content
export get_closest_nodes, announce_content!, query_content_location

using ..Types: AccountID, Hash
using ..ContentTypes

# Kademlia-inspired DHT node
struct DHTNode
    node_id::AccountID
    address::String  # IP:Port
    last_seen::Int64
    reputation::Float64
end

# Distributed Hash Table for content location
mutable struct DHT
    nodes::Dict{AccountID,DHTNode}
    content_locations::Dict{Hash,Set{AccountID}}  # Content hash -> nodes hosting it
    node_contents::Dict{AccountID,Set{Hash}}  # Node -> content it hosts
    replication_factor::Int  # How many nodes should store each content (Fibonacci: 5)
end

function DHT(replication_factor::Int=5)
    DHT(
        Dict{AccountID,DHTNode}(),
        Dict{Hash,Set{AccountID}}(),
        Dict{AccountID,Set{Hash}}(),
        replication_factor
    )
end

# Add node to DHT
function add_node!(dht::DHT, node::DHTNode)
    dht.nodes[node.node_id] = node
    if !haskey(dht.node_contents, node.node_id)
        dht.node_contents[node.node_id] = Set{Hash}()
    end
    @info "Node added to DHT" node_id=node.node_id address=node.address
end

# Remove node from DHT
function remove_node!(dht::DHT, node_id::AccountID)
    if !haskey(dht.nodes, node_id)
        return
    end
    
    # Remove all content locations for this node
    if haskey(dht.node_contents, node_id)
        for content_hash in dht.node_contents[node_id]
            if haskey(dht.content_locations, content_hash)
                delete!(dht.content_locations[content_hash], node_id)
            end
        end
        delete!(dht.node_contents, node_id)
    end
    
    delete!(dht.nodes, node_id)
    @info "Node removed from DHT" node_id=node_id
end

# XOR distance metric (simplified Kademlia)
function xor_distance(id1::String, id2::String)::Int
    # Simple hash-based distance
    h1 = hash(id1)
    h2 = hash(id2)
    return count_ones(xor(h1, h2))
end

# Find K closest nodes to a hash
function get_closest_nodes(dht::DHT, target_hash::Hash, k::Int=8)::Vector{DHTNode}
    if isempty(dht.nodes)
        return DHTNode[]
    end
    
    # Calculate distances
    distances = Tuple{Int,DHTNode}[]
    for node in values(dht.nodes)
        dist = xor_distance(target_hash, node.node_id)
        push!(distances, (dist, node))
    end
    
    # Sort by distance and take K closest
    sort!(distances, by=x->x[1])
    return [node for (_, node) in distances[1:min(k, length(distances))]]
end

# Announce that a node is hosting content
function announce_content!(
    dht::DHT,
    node_id::AccountID,
    content_hash::Hash
)::Bool
    if !haskey(dht.nodes, node_id)
        @warn "Node not in DHT" node_id=node_id
        return false
    end
    
    # Add to content locations
    if !haskey(dht.content_locations, content_hash)
        dht.content_locations[content_hash] = Set{AccountID}()
    end
    push!(dht.content_locations[content_hash], node_id)
    
    # Add to node's content list
    if !haskey(dht.node_contents, node_id)
        dht.node_contents[node_id] = Set{Hash}()
    end
    push!(dht.node_contents[node_id], content_hash)
    
    @info "Content announced" node_id=node_id content_hash=content_hash
    return true
end

# Store content in DHT (select replication_factor nodes)
function store_content!(
    dht::DHT,
    content_hash::Hash,
    data::Vector{UInt8}
)::Vector{AccountID}
    # Find closest nodes to store content
    closest = get_closest_nodes(dht, content_hash, dht.replication_factor * 2)
    
    if isempty(closest)
        @error "No nodes available for storage"
        return AccountID[]
    end
    
    # Select replication_factor nodes based on reputation
    sort!(closest, by=node->node.reputation, rev=true)
    selected = closest[1:min(dht.replication_factor, length(closest))]
    
    stored_at = AccountID[]
    for node in selected
        # In real implementation, would send data to node
        announce_content!(dht, node.node_id, content_hash)
        push!(stored_at, node.node_id)
    end
    
    @info "Content stored" content_hash=content_hash nodes=length(stored_at)
    return stored_at
end

# Find nodes hosting content
function find_content(dht::DHT, content_hash::Hash)::Vector{DHTNode}
    if !haskey(dht.content_locations, content_hash)
        return DHTNode[]
    end
    
    node_ids = dht.content_locations[content_hash]
    nodes = DHTNode[]
    
    for node_id in node_ids
        if haskey(dht.nodes, node_id)
            push!(nodes, dht.nodes[node_id])
        end
    end
    
    # Sort by reputation (prefer high-reputation nodes)
    sort!(nodes, by=node->node.reputation, rev=true)
    
    return nodes
end

# Query content location (with fallback to closest nodes)
function query_content_location(dht::DHT, content_hash::Hash)::Vector{DHTNode}
    # First try direct lookup
    nodes = find_content(dht, content_hash)
    
    if !isempty(nodes)
        return nodes
    end
    
    # If not found, return closest nodes that might know
    return get_closest_nodes(dht, content_hash, 8)
end

# Update node's last seen timestamp
function update_node_activity!(dht::DHT, node_id::AccountID)
    if haskey(dht.nodes, node_id)
        node = dht.nodes[node_id]
        updated = DHTNode(
            node.node_id,
            node.address,
            time_ns() ÷ 1_000_000_000,
            node.reputation
        )
        dht.nodes[node_id] = updated
    end
end

# Update node reputation
function update_node_reputation!(dht::DHT, node_id::AccountID, new_reputation::Float64)
    if haskey(dht.nodes, node_id)
        node = dht.nodes[node_id]
        updated = DHTNode(
            node.node_id,
            node.address,
            node.last_seen,
            clamp(new_reputation, 0.0, 1.0)
        )
        dht.nodes[node_id] = updated
    end
end

# Remove stale nodes (not seen for 377 seconds - Fibonacci)
function prune_stale_nodes!(dht::DHT, staleness_threshold::Int64=377)
    now = time_ns() ÷ 1_000_000_000
    cutoff = now - staleness_threshold
    
    stale_nodes = AccountID[]
    for (node_id, node) in dht.nodes
        if node.last_seen < cutoff
            push!(stale_nodes, node_id)
        end
    end
    
    for node_id in stale_nodes
        remove_node!(dht, node_id)
    end
    
    if !isempty(stale_nodes)
        @info "Pruned stale nodes" count=length(stale_nodes)
    end
end

end # module
