using Test
using Dates

include(joinpath(@__DIR__, "..", "src", "AequChain.jl"))


@testset "Committee selection determinism" begin
    members = ["validator_$(i)" for i in 1:16]
    committee1, idx1 = AequChain.select_committee(members; committee_size=8, epoch=UInt64(5), account="alice", seq=UInt64(10))
    committee2, idx2 = AequChain.select_committee(members; committee_size=8, epoch=UInt64(5), account="alice", seq=UInt64(10))

    @test committee1.members == committee2.members
    @test committee1.id == committee2.id
    @test idx1 == idx2
    @test length(unique(committee1.members)) == length(committee1.members)
end

@testset "Committee selection handles small pools" begin
    committee, idxmap = AequChain.select_committee(["a", "b"]; committee_size=4, epoch=UInt64(1), account="seed", seq=UInt64(0))

    @test length(committee.members) == 2
    @test Set(keys(idxmap)) == Set(committee.members)
    @test all(idxmap[member] == position for (position, member) in enumerate(committee.members))
end

@testset "Committee rotation across epochs and sequences" begin
    members = ["validator_$(i)" for i in 1:32]
    epoch_committee_ids = String[]
    for epoch in 1:5
        committee, idx = AequChain.select_committee(members; committee_size=16, epoch=UInt64(epoch), account="seed", seq=UInt64(0))

        @test length(committee.members) == 16
    @test length(Set(committee.members)) == length(committee.members)
        @test issubset(Set(committee.members), Set(members))

        push!(epoch_committee_ids, committee.id)
        for (member, position) in idx
            @test committee.members[position] == member
        end
    end

    @test length(unique(epoch_committee_ids)) == length(epoch_committee_ids)

    base_committee, _ = AequChain.select_committee(members; committee_size=16, epoch=UInt64(1), account="seed", seq=UInt64(0))
    for seq in 1:4
        committee, _ = AequChain.select_committee(members; committee_size=16, epoch=UInt64(1), account="seed", seq=UInt64(seq))
        @test committee.id != base_committee.id
    end
end

@testset "Quorum certificate aggregation" begin
    members = ["v1", "v2", "v3", "v4"]
    committee = AequChain.Types.Committee(0, "cid", members)
    block_hash = fill(UInt8(0x42), 32)

    votes = AequChain.Types.PartialVote[]
    for i in 1:3
        push!(votes, AequChain.Types.PartialVote(block_hash, committee.epoch, committee.id, members[i], i, fill(UInt8(i), 8)))
    end

    qc = AequChain.aggregate_qc(votes, committee, 3)
    @test qc !== nothing
    @test qc.block_hash == block_hash
    @test sum(qc.bitmap) == 3
    @test qc.threshold == 3
    @test length(qc.agg_sig) == 24

    duplicate_vote = AequChain.Types.PartialVote(block_hash, committee.epoch, committee.id, members[1], 1, fill(UInt8(0xFF), 8))
    votes_with_duplicate = copy(votes)
    push!(votes_with_duplicate, duplicate_vote)
    qc_with_duplicate = AequChain.aggregate_qc(votes_with_duplicate, committee, 3)
    @test qc_with_duplicate !== nothing
    @test sum(qc_with_duplicate.bitmap) == 3
    @test qc_with_duplicate.agg_sig == qc.agg_sig

    qc_insufficient = AequChain.aggregate_qc(votes[1:2], committee, 3)
    @test qc_insufficient === nothing

    conflicting_votes = AequChain.Types.PartialVote[
        AequChain.Types.PartialVote(fill(UInt8(0x01), 32), committee.epoch, committee.id, members[1], 1, fill(UInt8(1), 8)),
        AequChain.Types.PartialVote(fill(UInt8(0x02), 32), committee.epoch, committee.id, members[2], 2, fill(UInt8(2), 8))
    ]
    @test_throws AssertionError AequChain.aggregate_qc(conflicting_votes, committee, 2)
end

@testset "Quorum aggregation boundary conditions" begin
    members = ["v1", "v2", "v3", "v4"]
    committee = AequChain.Types.Committee(1, "boundary", members)
    block_hash = fill(UInt8(0x24), 32)

    votes = AequChain.Types.PartialVote[
        AequChain.Types.PartialVote(block_hash, committee.epoch, committee.id, members[i], i, fill(UInt8(0x10 + i), 8))
        for i in 1:3
    ]

    qc_high_threshold = AequChain.aggregate_qc(votes, committee, 4)
    @test qc_high_threshold === nothing

    outsider_vote = AequChain.Types.PartialVote(block_hash, committee.epoch, committee.id, "outsider", length(committee.members) + 1, fill(UInt8(0xFF), 8))
    zero_index_vote = AequChain.Types.PartialVote(block_hash, committee.epoch, committee.id, "zero", 0, fill(UInt8(0xEE), 8))
    padded_votes = vcat(votes, [outsider_vote, zero_index_vote])

    qc_with_padding = AequChain.aggregate_qc(padded_votes, committee, 3)
    @test qc_with_padding !== nothing
    @test sum(qc_with_padding.bitmap) == 3
    @test qc_with_padding.agg_sig == reduce(vcat, (v.partial_sig for v in votes); init=UInt8[])
end
