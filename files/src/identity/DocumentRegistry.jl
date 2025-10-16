module DocumentRegistry

export DocumentStore, register_document!, verify_document, list_documents
export is_document_expired, revoke_document!

using ..Types: AccountID, Hash
using ..IdentityTypes

# Document storage system
mutable struct DocumentStore
    documents::Dict{Hash,DocumentHash}  # All registered documents by hash
    account_documents::Dict{AccountID,Vector{Hash}}  # Documents per account
    revoked::Set{Hash}  # Revoked document hashes
end

function DocumentStore()
    DocumentStore(
        Dict{Hash,DocumentHash}(),
        Dict{AccountID,Vector{Hash}}(),
        Set{Hash}()
    )
end

# Register a document hash (never store raw document)
function register_document!(
    store::DocumentStore,
    account_id::AccountID,
    doc::DocumentHash
)::Bool
    if haskey(store.documents, doc.hash)
        @warn "Document already registered" hash=doc.hash
        return false
    end
    
    # Validate document type
    valid_types = [
        "national_id", "passport", "drivers_license",
        "business_registration", "tax_id", "operating_license",
        "health_permit", "professional_license"
    ]
    
    if !(doc.doc_type in valid_types)
        @error "Invalid document type" type=doc.doc_type
        return false
    end
    
    # Validate expiry (if present)
    if doc.expiry !== nothing
        now = time_ns() ÷ 1_000_000_000
        if doc.expiry < now
            @error "Document already expired" hash=doc.hash expiry=doc.expiry
            return false
        end
    end
    
    # Store document
    store.documents[doc.hash] = doc
    
    if !haskey(store.account_documents, account_id)
        store.account_documents[account_id] = Hash[]
    end
    push!(store.account_documents[account_id], doc.hash)
    
    @info "Document registered" account_id=account_id type=doc.doc_type issuer=doc.issuer_code
    return true
end

# Verify a document exists and is valid
function verify_document(store::DocumentStore, doc_hash::Hash)::Bool
    if !haskey(store.documents, doc_hash)
        return false
    end
    
    if doc_hash in store.revoked
        return false
    end
    
    doc = store.documents[doc_hash]
    
    # Check expiry
    if doc.expiry !== nothing
        now = time_ns() ÷ 1_000_000_000
        if doc.expiry < now
            return false
        end
    end
    
    return true
end

# Check if document is expired
function is_document_expired(store::DocumentStore, doc_hash::Hash)::Bool
    if !haskey(store.documents, doc_hash)
        return true
    end
    
    doc = store.documents[doc_hash]
    
    if doc.expiry === nothing
        return false  # No expiry date
    end
    
    now = time_ns() ÷ 1_000_000_000
    return doc.expiry < now
end

# Revoke a document (for lost/stolen documents)
function revoke_document!(store::DocumentStore, doc_hash::Hash)::Bool
    if !haskey(store.documents, doc_hash)
        return false
    end
    
    push!(store.revoked, doc_hash)
    @info "Document revoked" hash=doc_hash
    return true
end

# List all documents for an account
function list_documents(store::DocumentStore, account_id::AccountID)::Vector{DocumentHash}
    hashes = get(store.account_documents, account_id, Hash[])
    docs = DocumentHash[]
    
    for hash in hashes
        if haskey(store.documents, hash)
            push!(docs, store.documents[hash])
        end
    end
    
    return docs
end

# Get document by hash
function get_document(store::DocumentStore, doc_hash::Hash)::Union{DocumentHash,Nothing}
    return get(store.documents, doc_hash, nothing)
end

# Count valid (non-expired, non-revoked) documents for account
function count_valid_documents(store::DocumentStore, account_id::AccountID)::Int
    hashes = get(store.account_documents, account_id, Hash[])
    valid_count = 0
    
    for hash in hashes
        if verify_document(store, hash)
            valid_count += 1
        end
    end
    
    return valid_count
end

end # module
