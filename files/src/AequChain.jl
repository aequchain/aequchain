module AequChain

# Re-exports for public API - Core Blockchain
export AccountID, Hash, BlockHeader, SendBlock, ReceiveBlock, QuorumCert
export AccountState, apply_send!, apply_receive!
export Committee, CommitteeMember, select_committee
export PartialVote, aggregate_qc
export rate_limit_check!, maybe_do_pow!
export hash_block
export NodeConfig, InMemoryNode, register_account!, submit_payment!, get_account_balance
export list_blocks, list_quorum_certs, metrics_snapshot, projected_capacity, memory_breakdown

# Re-exports for Identity System
export IdentityTier, TierLimits, DocumentHash, AnonymousIdentity, DocumentedIdentity
export BusinessIdentity, VouchRecord, LicenseRecord, BiometricBinding
export IdentityRegistry, register_anonymous!, register_documented!, register_business!
export add_vouch!, check_tier_limits, get_identity_tier, upgrade_to_tier1!
export DocumentStore, register_document!, verify_document
export BusinessStore, register_business!, get_business

# Re-exports for AequNet
export ContentChunk, ContentManifest, NodeContentRegistry, EncryptedContent
export ContentMetadata, ContentAccessControl
export DHTNode, DHT, add_node!, store_content!, find_content
export ContentStore, chunk_content, publish_to_aequnet!, retrieve_content

# Re-exports for API
export APIRequest, APIResponse, APIError, ErrorCode
export AccountCreateRequest, TransactionRequest, PledgeRequest
export JobRequest, EnterpriseRequest, ContentPublishRequest

# Core blockchain types and modules
include("types/Types.jl")
include("network/Messages.jl")
using .Messages: hash_block
using .Types: AccountID, Hash, BlockHeader, SendBlock, ReceiveBlock, QuorumCert
using .Types: Committee, CommitteeMember, PartialVote, AccountState

# Identity types and modules
include("types/IdentityTypes.jl")
using .IdentityTypes

include("identity/PoP.jl")
include("identity/IdentityTiers.jl")
using .IdentityTiers

include("identity/SocialVouching.jl")
using .SocialVouching

include("identity/DocumentRegistry.jl")
using .DocumentRegistry

include("identity/BusinessRegistry.jl")
using .BusinessRegistry

# Content/AequNet types and modules
include("types/ContentTypes.jl")
using .ContentTypes

include("network/ContentDHT.jl")
using .ContentDHT

include("network/ContentServer.jl")
using .ContentServer

# API types
include("types/APITypes.jl")
using .APITypes

# State management
include("state/State.jl")
using .State: apply_send!, apply_receive!

# Consensus
include("consensus/CommitteeSelection.jl")
using .CommitteeSelection: select_committee

include("consensus/Aggregation.jl")
using .Aggregation: aggregate_qc

# Anti-spam
include("anti_spam/RateLimiter.jl")
using .RateLimiter: rate_limit_check!

include("anti_spam/PoW.jl")
using .PoW: maybe_do_pow!

# Networking
include("network/Gossip.jl")

# Node
include("node/TestnetNode.jl")
using .TestnetNode: NodeConfig, InMemoryNode, register_account!, submit_payment!, get_account_balance
using .TestnetNode: list_blocks, list_quorum_certs, metrics_snapshot, projected_capacity, memory_breakdown

end # module