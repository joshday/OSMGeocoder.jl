module OSMGeocoder

using HTTP, GeoJSON
using DBInterface, SQLite, Scratch  # For caching

export geocode

#-----------------------------------------------------------------------------# init
dbpath::String = ""
db::SQLite.DB = SQLite.DB()
user_agent::String = ""

function __init__()
    global user_agent = string(hash(rand()))  # random user agent to avoid rate limiting
    global dbpath = joinpath(Scratch.@get_scratch!("cache"), "db.sqlite")
    global db = SQLite.DB(dbpath)
    DBInterface.execute(db, """
        CREATE TABLE IF NOT EXISTS kv (
            key BLOB PRIMARY KEY,
            value BLOB
        ) WITHOUT ROWID;
    """)
    return
end

#-----------------------------------------------------------------------------# utils
const base_url = "https://nominatim.openstreetmap.org/search?"

function param_str(; kw...)
    out = String[]
    for (k, v) in kw
        push!(out, "$k=$(HTTP.escapeuri(v))")
    end
    return join(out, "&")
end

default_params = (; format = "geojson", polygon_geojson = "1")

url(; kw...) = base_url * param_str(; default_params..., kw...)

# "hash" function that doesn't depend on order
get_key(kw) = string(NamedTuple(kw)[sort(collect(keys(kw)))])

empty_db!() = DBInterface.execute(db, "DELETE FROM kv;")

cache() = ((;key, value=GeoJSON.read(value)) for (key,value) in DBInterface.execute(db, "SELECT * FROM kv;"))

# Look up value in DB.  Returns `nothing` if not found.
lookup(q) = lookup(; q)

function lookup(; kw...)
    key = get_key(kw)
    res = DBInterface.execute(db, "SELECT value FROM kv WHERE key = ?", (key,))
    return isempty(res) ? nothing : GeoJSON.read(first(res)[1])
end

#-----------------------------------------------------------------------------# geocode
geocode(q::AbstractString) = geocode(; q)

function geocode(; kw...)
    val = lookup(; kw...)
    if isnothing(val)
        res = HTTP.get(url(; kw...), ["User-Agent" => user_agent])
        DBInterface.execute(db, "INSERT INTO kv (key, value) VALUES (?, ?);", (get_key(kw), res.body))
        out = GeoJSON.read(res.body)
    else
        return val
    end
end

end
