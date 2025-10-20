# OSMGeocoder

[![Build Status](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/CI.yml?query=branch%3Amain)

Geocoding via OpenStreetMap's [Nominatum](https://nominatim.org/release-docs/develop/).

## Usage

- `OSMGeocoder.geocode` always returns a `GeoJSON.FeatureCollection`.
- Query results are stored in a SQLite database stored in a Scratch.jl scratchspace.
- For keyword arguments that can be passed to `geocode(; kw...)`, see the [Nominatum Search Queries](https://nominatim.org/release-docs/develop/api/Search/) documentation.

```julia
using OSMGeocoder: geocode

# General query.  This will match both the city and the state (2 geometries)
geocode("New York")

# Structured query via keywords (:amenity, :street, :city, :county, :state, :country, :postalcode)
# This matches just the city geometry
geocode(city = "New York")
```
