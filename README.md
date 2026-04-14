# OSMGeocoder

[![Build Status](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/CI.yml?query=branch%3Amain)

Geocoding via OpenStreetMap's [Nominatum](https://nominatim.org/release-docs/develop/).

## Usage

- `OSMGeocoder.geocode` always returns a `GeoJSON.FeatureCollection`.
- Queries are cached in scratchspace unless a `cache=false` keyword arg is provided.

```julia
geocode("New York")  # free-form query -- returns both city and state geometries

# geocode(; amenity, street, city, county, state, country, postalcode)
geocode(city = "New York")  # structured query -- returns only city geometry
```

## Details

- `geocode(q; kw...)` simply wraps `fetch(Query(q; kw...); force=false)`
  - Use `force=true` to trigger a fresh download
- Both the `Query` and the downloaded GeoJSON are saved to the cache.


```julia
OSMGeocoder.list()  # Vector{Query} of cached queries

ny = OSMGeocoder.Query(city = "New York")
OSMGeocoder.fetch(ny)  # If you ran the example above, this loads cached geojson

OSMGeocoder.delete!!(ny)  # Remove query from cache

OSMGeocoder.clear_cache!!()  # Remove all cached queries
```
