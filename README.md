[![CI](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/CI.yml)
[![Docs Build](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/Docs.yml/badge.svg)](https://github.com/joshday/OSMGeocoder.jl/actions/workflows/Docs.yml)
[![Stable Docs](https://img.shields.io/badge/docs-stable-blue)](https://joshday.github.io/OSMGeocoder.jl/stable/)
[![Dev Docs](https://img.shields.io/badge/docs-dev-blue)](https://joshday.github.io/OSMGeocoder.jl/dev/)

# OSMGeocoder


Geocoding via OpenStreetMap's [Nominatum](https://nominatim.org/release-docs/develop/).

## Usage

- `OSMGeocoder.geocode` always returns a `GeoJSON.FeatureCollection`.
- Queries are cached in a SQLite database (stored in scratchspace).
- For keyword arguments that can be passed to `geocode(; kw...)`, see the [Nominatum Search Queries](https://nominatim.org/release-docs/develop/api/Search/) documentation.

```julia
using OSMGeocoder: geocode

# General query.  This will match both the city and the state (2 geometries)
geocode("New York")

# Structured query via keywords (:amenity, :street, :city, :county, :state, :country, :postalcode)
# This matches just the city geometry
geocode(city = "New York")
```
