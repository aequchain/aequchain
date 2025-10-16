#!/usr/bin/env julia

# Standalone launcher for aequchain testnet API server
# Usage: julia start-api.jl

using Pkg
Pkg.instantiate()

using HTTP
using JSON3
using SHA
using Base64
using Dates

# Load core types
include("files/src/types/Types.jl")
using .Types

# Load messages (needed by State)
include("files/src/network/Messages.jl")
using .Messages

# Load state management
include("files/src/state/State.jl")
using .State

# Load anti-spam (needed by TestnetNode)
include("files/src/anti_spam/RateLimiter.jl")
using .RateLimiter

# Load consensus modules (needed by TestnetNode)
include("files/src/consensus/CommitteeSelection.jl")
using .CommitteeSelection

include("files/src/consensus/Aggregation.jl")
using .Aggregation

# Load node implementation (exports InMemoryNode)
include("files/src/node/TestnetNode.jl")
using .TestnetNode

# Load content modules
include("files/src/types/ContentTypes.jl")
using .ContentTypes

# Load DHT first (ContentServer needs it)
include("files/src/network/ContentDHT.jl")
using .ContentDHT

include("files/src/network/ContentServer.jl")
using .ContentServer

# Load API server
include("files/src/network/APIServer.jl")
using .APIServer

println("=" ^ 60)
println("🚀 AEQU CHAIN TESTNET API SERVER")
println("=" ^ 60)
println("")
println("⚠️  DEMO MODE - NO REAL VALUE - EPHEMERAL ONLY")
println("")
println("Starting server on http://localhost:3000")
println("Press Ctrl+C to stop")
println("")
println("=" ^ 60)
println("")

try
    APIServer.start_server(host="127.0.0.1", port=3000)
catch e
    if isa(e, InterruptException)
        println("\n\n✅ Server stopped gracefully")
    else
        println("\n\n❌ Server error: $e")
        rethrow(e)
    end
end
