using Test, ResultTypes

using SFAPI

@testset "Status" begin
    @test length(SFAPI.Status.CenterStatus(SFAPI.Query.get("status"))) > 0
end
