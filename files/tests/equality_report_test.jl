using Test

include(joinpath(@__DIR__, "..", "..", "aequchain.jl"))

@testset "Equality report structured output" begin
    reset_state!()
    init_treasury(1000.0, "USD", 1.0, "founder")
    join_member("alice")

    results = gather_equality_results()
    buf = IOBuffer()
    ok = render_equality_report(results; interactive=false, format=:json, io=buf)

    @test ok
    payload = String(take!(buf))
    @test startswith(payload, "{")
    @test occursin("\"checks\"", payload)
    @test occursin("\"ok\":true", payload)
end

@testset "Equality report rejects unknown format" begin
    reset_state!()
    init_treasury(500.0, "USD", 1.0, "seed")
    join_member("bob")

    results = gather_equality_results()
    @test_throws ArgumentError render_equality_report(results; interactive=false, format=:unsupported)
end
