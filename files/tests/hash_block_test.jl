#!/usr/bin/env julia

using Test
using Dates

include(joinpath(@__DIR__, "..", "src", "AequChain.jl"))
using .AequChain

const Types = AequChain.Types
const hash_block = AequChain.hash_block

function make_send_block(; amount::UInt128=UInt128(10))
    header = Types.BlockHeader(
        "acc_1",
        fill(UInt8(0x00), 32),
        UInt64(1),
        fill(UInt8(0x11), 32),
        UInt64(0),
        now(),
        fill(UInt8(0x22), 32)
    )
    payload = Types.SendPayload("acc_2", amount, fill(UInt8(0x33), 32))
    sig = fill(UInt8(0x44), 64)
    return Types.SendBlock(header, payload, sig)
end

@testset "hash_block determinism" begin
    blk1 = make_send_block()
    blk2 = make_send_block()
    h1 = hash_block(blk1)
    h2 = hash_block(blk2)
    @test h1 == h2
end

@testset "hash_block sensitivity" begin
    blk = make_send_block()
    h_base = hash_block(blk)

    blk_diff = make_send_block(amount=UInt128(11))
    h_diff = hash_block(blk_diff)
    @test h_base != h_diff
end
