module APIServer

using HTTP
using JSON3
using ..Types
using ..Types: AccountID, Hash
using ..TestnetNode
using ..ContentServer
using ..ContentDHT

# In-memory testnet state (ephemeral - resets on restart)
const TESTNET_NODE = Ref{Union{Nothing, TestnetNode.InMemoryNode}}(nothing)
const CONTENT_STORE = Ref{Union{Nothing, ContentServer.ContentStore}}(nothing)
const DHT = Ref{Union{Nothing, ContentDHT.DHT}}(nothing)

"""
Initialize ephemeral testnet state.
DEMO MODE: All data lost on server restart.
"""
function init_testnet!()
    println("🔧 Initializing ephemeral testnet (DEMO MODE)...")
    
    # Create testnet node
    TESTNET_NODE[] = TestnetNode.InMemoryNode(
        TestnetNode.NodeConfig(committee_size=5, threshold=3, epoch_seed=UInt64(42))
    )
    
    # Create DHT first (ContentStore needs it) - replication_factor = 5
    DHT[] = ContentDHT.DHT(5)
    
    # Create content storage (needs node_id and DHT)
    CONTENT_STORE[] = ContentServer.ContentStore(
        AccountID("testnet-node-1"),
        DHT[]
    )
    
    println("✅ Testnet initialized (ephemeral, non-persisting)")
end

"""
CORS headers for Flutter web app.
"""
function cors_headers()
    return [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type",
        "Content-Type" => "application/json"
    ]
end

"""
Handle OPTIONS preflight requests.
"""
function handle_options(req::HTTP.Request)
    return HTTP.Response(200, cors_headers())
end

"""
POST /api/testnet/reset
Reset testnet to initial state.
"""
function handle_reset(req::HTTP.Request)
    try
        init_testnet!()
        
        response = Dict(
            "status" => "success",
            "message" => "Testnet reset (all data cleared)",
            "demo_mode" => true
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
POST /api/testnet/account/create
Create new testnet account.

Body: { "account_id": "alice", "initial_balance": 1000 }
"""
function handle_create_account(req::HTTP.Request)
    try
        body = JSON3.read(String(req.body))
        account_id = get(body, :account_id, "")
        balance = get(body, :initial_balance, UInt128(1000))
        
        if isempty(account_id)
            return HTTP.Response(400, cors_headers(), JSON3.write(Dict(
                "status" => "error",
                "message" => "account_id required"
            )))
        end
        
        # Register account
        TestnetNode.register_account!(TESTNET_NODE[], account_id; initial_balance=UInt128(balance))
        
        response = Dict(
            "status" => "success",
            "account_id" => account_id,
            "balance" => string(balance),
            "demo_mode" => true,
            "message" => "Account created (ephemeral)"
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
GET /api/testnet/account/:id/balance
Get account balance.
"""
function handle_get_balance(req::HTTP.Request, account_id::String)
    try
        balance = TestnetNode.get_account_balance(TESTNET_NODE[], account_id)
        
        response = Dict(
            "status" => "success",
            "account_id" => account_id,
            "balance" => string(balance),
            "demo_mode" => true
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(404, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => "Account not found or error: $(string(e))"
        )))
    end
end

"""
POST /api/testnet/transaction/send
Submit transaction.

Body: { "from": "alice", "to": "bob", "amount": 100 }
"""
function handle_send_transaction(req::HTTP.Request)
    try
        body = JSON3.read(String(req.body))
        from = get(body, :from, "")
        to = get(body, :to, "")
        amount = get(body, :amount, 0)
        
        if isempty(from) || isempty(to) || amount <= 0
            return HTTP.Response(400, cors_headers(), JSON3.write(Dict(
                "status" => "error",
                "message" => "from, to, and amount (>0) required"
            )))
        end
        
        # Submit payment
        result = TestnetNode.submit_payment!(TESTNET_NODE[], from, to, UInt128(amount))
        
        response = Dict(
            "status" => "success",
            "from" => from,
            "to" => to,
            "amount" => string(amount),
            "send_block_hash" => bytes2hex(result.send_qc.block_hash[1:8]),
            "recv_block_hash" => bytes2hex(result.recv_qc.block_hash[1:8]),
            "demo_mode" => true,
            "message" => "Transaction submitted (ephemeral)"
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
GET /api/testnet/stats
Get testnet statistics.
"""
function handle_get_stats(req::HTTP.Request)
    try
        node = TESTNET_NODE[]
        metrics = TestnetNode.metrics_snapshot(node)
        
        response = Dict(
            "status" => "success",
            "total_accounts" => length(node.state.accounts),
            "total_transactions" => length(node.blocks),
            "blocks" => length(node.blocks),
            "quorum_certs" => length(node.quorum_certs),
            "throughput_tps" => metrics.throughput_tps,
            "avg_latency_ms" => metrics.avg_latency_ms,
            "memory_bytes" => metrics.memory.total_bytes,
            "active_nodes" => 1,  # Single node testnet
            "demo_mode" => true,
            "ephemeral" => true
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
GET /api/testnet/accounts
Get all accounts with balances (for demo UI).
"""
function handle_get_all_accounts(req::HTTP.Request)
    try
        node = TESTNET_NODE[]
        
        # Build array of accounts with balances
        accounts_list = []
        for (account_id, account_state) in node.state.accounts
            push!(accounts_list, Dict(
                "account_id" => string(account_id),
                "balance" => string(account_state.balance)
            ))
        end
        
        response = Dict(
            "status" => "success",
            "accounts" => accounts_list,
            "count" => length(accounts_list),
            "demo_mode" => true
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
POST /api/testnet/rebalance
Rebalance all accounts to equal distribution.
Demonstrates the equality mechanism.
"""
function handle_rebalance(req::HTTP.Request)
    try
        node = TESTNET_NODE[]
        
        if isempty(node.state.accounts)
            return HTTP.Response(200, cors_headers(), JSON3.write(Dict(
                "status" => "success",
                "message" => "No accounts to rebalance",
                "total_accounts" => 0,
                "demo_mode" => true
            )))
        end
        
        # Calculate total treasury and equal share
        total_accounts = length(node.state.accounts)
        total_balance = sum(acc_state.balance for (_, acc_state) in node.state.accounts)
        equal_share = total_balance ÷ total_accounts
        
        # Rebalance all accounts to equal share (create new AccountState for each)
        for (account_id, old_state) in node.state.accounts
            new_state = Types.AccountState(
                equal_share,  # new balance
                old_state.head,
                old_state.nonce,
                old_state.rep_id
            )
            node.state.accounts[account_id] = new_state
        end
        
        response = Dict(
            "status" => "success",
            "message" => "All accounts rebalanced to equal distribution",
            "total_accounts" => total_accounts,
            "total_treasury" => string(total_balance),
            "equal_share" => string(equal_share),
            "demo_mode" => true
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
POST /api/testnet/content/publish
Publish content to AequNet (ephemeral).

Body: { "title": "Test Content", "data": "base64_encoded_data" }
"""
function handle_publish_content(req::HTTP.Request)
    try
        body = JSON3.read(String(req.body))
        title = get(body, :title, "Untitled")
        data_b64 = get(body, :data, "")
        
        if isempty(data_b64)
            return HTTP.Response(400, cors_headers(), JSON3.write(Dict(
                "status" => "error",
                "message" => "data (base64) required"
            )))
        end
        
        # Decode and store
        data = base64decode(data_b64)
        content_hash = ContentServer.store_content!(CONTENT_STORE[], DHT[], data, Dict("title" => title))
        
        response = Dict(
            "status" => "success",
            "content_hash" => bytes2hex(content_hash),
            "title" => title,
            "size_bytes" => length(data),
            "demo_mode" => true,
            "message" => "Content published (ephemeral, lost on restart)"
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
GET /api/testnet/content/list
List published content.
"""
function handle_list_content(req::HTTP.Request)
    try
        store = CONTENT_STORE[]
        manifests = collect(values(store.manifests))
        
        content_list = [
            Dict(
                "hash" => bytes2hex(m.root_hash),
                "chunk_count" => length(m.chunk_hashes),
                "total_size" => m.total_size,
                "title" => get(m.metadata, "title", "Unknown")
            )
            for m in manifests
        ]
        
        response = Dict(
            "status" => "success",
            "content" => content_list,
            "count" => length(content_list),
            "demo_mode" => true
        )
        
        return HTTP.Response(200, cors_headers(), JSON3.write(response))
    catch e
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
Router - dispatch requests to handlers.
"""
function router(req::HTTP.Request)
    # Handle CORS preflight
    if req.method == "OPTIONS"
        return handle_options(req)
    end
    
    path = req.target
    method = req.method
    
    try
        # Health check
        if path == "/api/health"
            return HTTP.Response(200, cors_headers(), JSON3.write(Dict(
                "status" => "ok",
                "demo_mode" => true,
                "ephemeral" => true
            )))
        end
        
        # Testnet endpoints
        if path == "/api/testnet/reset" && method == "POST"
            return handle_reset(req)
        elseif path == "/api/testnet/account/create" && method == "POST"
            return handle_create_account(req)
        elseif startswith(path, "/api/testnet/account/") && endswith(path, "/balance") && method == "GET"
            account_id = split(path, "/")[5]
            return handle_get_balance(req, account_id)
        elseif path == "/api/testnet/transaction/send" && method == "POST"
            return handle_send_transaction(req)
        elseif path == "/api/testnet/stats" && method == "GET"
            return handle_get_stats(req)
        elseif path == "/api/testnet/accounts" && method == "GET"
            return handle_get_all_accounts(req)
        elseif path == "/api/testnet/rebalance" && method == "POST"
            return handle_rebalance(req)
        elseif path == "/api/testnet/content/publish" && method == "POST"
            return handle_publish_content(req)
        elseif path == "/api/testnet/content/list" && method == "GET"
            return handle_list_content(req)
        end
        
        # 404
        return HTTP.Response(404, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => "Endpoint not found"
        )))
        
    catch e
        println("Error handling request: ", e)
        return HTTP.Response(500, cors_headers(), JSON3.write(Dict(
            "status" => "error",
            "message" => string(e)
        )))
    end
end

"""
Start API server.
"""
function start_server(; host="127.0.0.1", port=3000)
    println("=" ^ 50)
    println("  🚀 aequchain TESTNET API SERVER")
    println("=" ^ 50)
    println()
    println("⚠️  DEMO MODE: Ephemeral, non-persisting")
    println()
    
    # Initialize testnet
    init_testnet!()
    
    println()
    println("📡 API Endpoints:")
    println("  POST   http://$host:$port/api/testnet/reset")
    println("  POST   http://$host:$port/api/testnet/account/create")
    println("  GET    http://$host:$port/api/testnet/account/:id/balance")
    println("  GET    http://$host:$port/api/testnet/accounts")
    println("  POST   http://$host:$port/api/testnet/rebalance")
    println("  POST   http://$host:$port/api/testnet/transaction/send")
    println("  GET    http://$host:$port/api/testnet/stats")
    println("  POST   http://$host:$port/api/testnet/content/publish")
    println("  GET    http://$host:$port/api/testnet/content/list")
    println()
    println("🌐 Flutter DApp: Connect to http://$host:$port")
    println()
    println("Press Ctrl+C to stop")
    println("=" ^ 50)
    println()
    
    # Start server
    HTTP.serve(router, host, port)
end

end # module
