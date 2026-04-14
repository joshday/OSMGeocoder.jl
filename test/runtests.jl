using OSMGeocoder
using Test

@testset "OSMGeocoder.jl" begin
    @testset "Query construction" begin
        q1 = OSMGeocoder.Query("New York")
        @test q1.q == "New York"
        @test q1.cache == true
        @test q1.city == ""

        q2 = OSMGeocoder.Query(city="New York", state="NY")
        @test q2.q == ""
        @test q2.city == "New York"
        @test q2.state == "NY"

        q3 = OSMGeocoder.Query("test"; cache=false)
        @test q3.cache == false
    end

    @testset "params" begin
        q = OSMGeocoder.Query(city="New York")
        p = OSMGeocoder.params(q)
        @test p["format"] == "geojson"
        @test p["polygon_geojson"] == "1"
        @test p["city"] == "New%20York"
        @test !haskey(p, "q")
        @test !haskey(p, "state")
    end

    @testset "url" begin
        q = OSMGeocoder.Query(city="Durham", state="NC")
        u = OSMGeocoder.url(q)
        @test startswith(u, "https://nominatim.openstreetmap.org/search?")
        @test contains(u, "city=Durham")
        @test contains(u, "state=NC")
    end

    @testset "geocode" begin
        res = geocode("Raleigh, NC")
        @test length(res) > 0
    end

    @testset "Cache" begin
        OSMGeocoder.clear_cache!!()
        @test isempty(OSMGeocoder.list())

        geocode("Raleigh, NC")
        @test length(OSMGeocoder.list()) == 1

        geocode(city="Durham", state="NC")
        @test length(OSMGeocoder.list()) == 2

        OSMGeocoder.clear_cache!!()
        @test isempty(OSMGeocoder.list())
    end
end
