using OSMGeocoder
using Test

@testset "OSMGeocoder.jl" begin
    res1 = geocode("New York")
    res2 = geocode(city = "New York")
    @test length(res1) == 2
    @test length(res2) == 1

    # test cache
    @test geocode("New York") === res1
    @test geocode(city = "New York") === res2
end
