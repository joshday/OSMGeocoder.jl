"""
    OSMGeocoder

Geocode addresses using the [OpenStreetMap Nominatim API](https://nominatim.openstreetmap.org/).
Results are returned as GeoJSON `FeatureCollection`s.  The main entry point is [`geocode`](@ref).
"""
module OSMGeocoder

using Scratch, HTTP, GeoJSON, Serialization

export geocode

#-----------------------------------------------------------------------------# init
user_agent::String = ""
cache_dir::String = ""

function __init__()
    global user_agent = string(hash(rand()))
    global cache_dir = get_scratch!("cache")
    return
end

#-----------------------------------------------------------------------------# Query
"""
    Query(q::String; cache::Bool=true)
    Query(; cache::Bool=true, amenity="", street="", city="", county="", state="", country="", postalcode="")

A geocoding query for the OpenStreetMap Nominatim API.  Use either a free-form query string `q`
or structured address fields.  Set `cache=false` to skip caching the result.
"""
struct Query
    q::String
    amenity::String
    street::String
    city::String
    county::String
    state::String
    country::String
    postalcode::String
    cache::Bool
    Query(q::String; cache::Bool=true) = new(q, "", "", "", "", "", "", "", cache)
    function Query(; cache::Bool=true, amenity="", street="", city="", county="", state="", country="", postalcode="")
        new("", amenity, street, city, county, state, country, postalcode, cache)
    end
end

"""
    params(qry::Query) -> Dict{String, String}

Build the HTTP query parameters dictionary for a Nominatim API request.
"""
function params(qry::Query)
    out = Dict("format" => "geojson", "polygon_geojson" => "1")
    for field in (:q, :amenity, :street, :city, :county, :state, :country, :postalcode)
        val = getfield(qry, field)
        isempty(val) || (out[string(field)] = HTTP.escapeuri(val))
    end
    return out
end

"""
    url(qry::Query) -> String

Construct the full Nominatim search URL for the given query.
"""
function url(qry::Query)
    "https://nominatim.openstreetmap.org/search?" * join(["$k=$v" for (k,v) in params(qry)], '&')
end

filenames(qry::Query) = (;
    geojson = joinpath(cache_dir, "osm_$(hash(qry)).geojson"),
    jld = joinpath(cache_dir, "osm_$(hash(qry)).jld")
)

"""
    fetch(qry::Query; force=false)

Fetch geocoding results for `qry`.  Returns cached results when available unless `force=true`.
"""
function fetch(qry::Query; force=false)
    (; geojson, jld) = filenames(qry)
    if force || !isfile(geojson) || !isfile(jld)
        res = HTTP.get(url(qry), ["User-Agent" => user_agent])
        out = GeoJSON.read(res.body)
        qry.cache && GeoJSON.write(geojson, out)
        qry.cache && serialize(jld, qry)
        return out
    end
    return GeoJSON.read(read(geojson, String))
end

"""
    list() -> Vector{Query}

Return all cached [`Query`](@ref) objects.
"""
function list()
    dir = get_scratch!("cache")
    return deserialize.(filter(x -> endswith(x, ".jld"), readdir(dir, join=true)))
end

"""
    delete!!(qry::Query)

Delete cached result files for the given query.
"""
function delete!!(qry::Query)
    (; geojson, jld) = filenames(qry)
    rm(geojson; force=true)
    rm(jld; force=true)
end

"""
    clear_cache!()

Delete all cached geocoding results.
"""
function clear_cache!!()
    for qry in list()
        delete!!(qry)
    end
end

#-----------------------------------------------------------------------------# geocode
"""
    geocode(q::String; cache::Bool=true)
    geocode(; cache::Bool=true, amenity="", street="", city="", county="", state="", country="", postalcode="")

Geocode an address using the OpenStreetMap Nominatim API.  Returns a GeoJSON `FeatureCollection`.

# Examples

```julia
geocode("New York")

geocode(city="New York", state="NY")
```
"""
geocode(q::String; cache::Bool=true) = fetch(Query(q; cache))

geocode(; kw...) = fetch(Query(; kw...))

end
