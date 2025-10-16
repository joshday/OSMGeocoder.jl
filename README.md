# OSMGeocoder

[![Build Status](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/CI.yml?query=branch%3Amain)

Geocoding via OpenStreetMap's [Nominatum](https://nominatim.org/release-docs/develop/).

## Usage

`OSMGeocoder.geocode` always returns a `GeoJSON.FeatureCollection`.  Queries are stored in per-Julia-session cache.

```julia
using OSMGeocoder: geocode

# General query.  This will match both the city and the state (2 geometries)
geocode("New York")

# Structured query via keywords (:amenity, :street, :city, :county, :state, :country, :postalcode)
geocode(city = "New York")
```
