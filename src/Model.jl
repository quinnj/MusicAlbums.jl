module Model

import Base: ==

using StructTypes

export Album

mutable struct Album
    id::Int64 # service-managed
    name::String
    artist::String
    year::Int64
    timespicked::Int64 # service-managed
    songs::Vector{String}
end

==(x::Album, y::Album) = x.id == y.id
Album() = Album(0, "", "", 0, 0, String[])
Album(name, artist, year, songs) = Album(0, name, artist, year, 0, songs)
StructTypes.StructType(::Type{Album}) = StructTypes.Mutable()
StructTypes.idproperty(::Type{Album}) = :id

end # module