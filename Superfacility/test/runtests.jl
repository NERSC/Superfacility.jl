using Test, ResultTypes

using Superfacility: SFAPI

@testset "Status" begin
    @test length(SFAPI.Status.CenterStatus(SFAPI.Query.get("status"))) > 0
end
