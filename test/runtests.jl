using OSMGeocoder
using Test

@testset "OSMGeocoder.jl" begin
    res1 = geocode("New York")
    res2 = geocode(city = "New York")
    @test length(res1) == 2
    @test length(res2) == 1

    @testset "Cache" begin
        OSMGeocoder.empty_db!()
        @test isempty(OSMGeocoder.cache())

        geocode("New York")
        geocode(city = "New York")
        @test length(collect(OSMGeocoder.cache())) == 2
    end
end
