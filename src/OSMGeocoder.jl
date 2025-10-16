module OSMGeocoder

using HTTP, JSON, GeoJSON, StyledStrings

import GeoInterface as GI
import Extents

export geocode

const base_url = "https://nominatim.openstreetmap.org/search?"

const cache = Dict{UInt64, GeoJSON.FeatureCollection}()

const user_agent = rand('A':'z', 8)  # random user agent to avoid rate limiting

#-----------------------------------------------------------------------------# utils
function param_str(; kw...)
    out = String[]
    for (k, v) in kw
        push!(out, "$k=$(HTTP.escapeuri(v))")
    end
    return join(out, "&")
end

default_params = (; format = "geojson", polygon_geojson = "1")

url(; kw...) = base_url * param_str(; default_params..., kw...)

# Hash function that doesn't depend on order
function hash_kw(kw)
    skeys = sort(collect(keys(kw)))
    svals = [string(kw[k]) for k in skeys]
    return hash(skeys, hash(svals))
end

#-----------------------------------------------------------------------------# geocode
geocode(q::AbstractString) = geocode(; q)

function geocode(; use_cache = true, kw...)
    h = hash_kw(kw)
    use_cache && haskey(cache, h) && return cache[h]
    res = HTTP.get(url(; kw...), ["User-Agent" => "OSMGeocoder.jl - $user_agent"])
    out = GeoJSON.read(res.body)
    return use_cache ? (cache[h] = out) : out
end

end
