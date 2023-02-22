module Model

import Base: ==

using StructTypes

export Album

mutable struct Album
    id::Int64 # service-managed
    name::String
    artist::String
    year::Int64
    songs::Vector{String}
    timespicked::Int64 # service-managed
end

==(x::Album, y::Album) = x.id == y.id
Album() = Album(0, "", "", 0, String[], 0)
Album(name, artist, year, songs) = Album(0, name, artist, year, songs, 0)
StructTypes.StructType(::Type{Album}) = StructTypes.Mutable()

end # module