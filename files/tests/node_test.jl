using Test

include(joinpath(@__DIR__, "..", "src", "AequChain.jl"))
using .AequChain: NodeConfig, InMemoryNode, register_account!, submit_payment!, get_account_balance, list_blocks, hash_block

@testset "Testnet in-memory node payments" begin
    node = InMemoryNode(NodeConfig(committee_size=4, threshold=2))
    register_account!(node, "alice"; initial_balance=UInt128(150))
    register_account!(node, "bob"; initial_balance=UInt128(50))
    register_account!(node, "carol"; initial_balance=UInt128(0))

    @test get_account_balance(node, "alice") == UInt128(150)
    @test get_account_balance(node, "bob") == UInt128(50)

    result = submit_payment!(node, "alice", "bob", UInt128(25))
    @test length(node.blocks) == 2
    @test length(node.quorum_certs) == 2
    @test get_account_balance(node, "alice") == UInt128(125)
    @test get_account_balance(node, "bob") == UInt128(75)
    @test result.send_block.payload.amount == UInt128(25)
    @test result.receive_block.payload.from_account == "alice"
    @test result.send_qc.block_hash == hash_block(result.send_block)

    result2 = submit_payment!(node, "bob", "carol", UInt128(60))
    @test get_account_balance(node, "bob") == UInt128(15)
    @test get_account_balance(node, "carol") == UInt128(60)
    @test length(node.blocks) == 4
    @test length(node.quorum_certs) == 4
    @test hash_block(result2.receive_block) != hash_block(result.receive_block)

    canonical_chain = list_blocks(node)
    @test length(canonical_chain) == 4
    @test all(occursin("\"type\":\"block", entry) for entry in canonical_chain)
end
