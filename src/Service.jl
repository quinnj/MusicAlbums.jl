module Service

using Dates, ExpiringCaches
using ..Model, ..Mapper

function createAlbum(obj)
    @assert haskey(obj, :name) && !isempty(obj.name)
    @assert haskey(obj, :artist) && !isempty(obj.artist)
    @assert haskey(obj, :songs) && !isempty(obj.songs)
    @assert haskey(obj, :year) && 1900 < obj.year < Dates.year(Dates.now())
    album = Album(obj.name, obj.artist, obj.year, obj.songs)
    Mapper.create!(album)
    return album
end

@cacheable Dates.Hour(1) function getAlbum(id::Int64)::Album
    Mapper.get(id)
end

function updateAlbum(id, updated)
    album = Mapper.get(id)
    album.name = updated.name
    album.artist = updated.artist
    album.year = updated.year
    album.songs = updated.songs
    Mapper.update(album)
    delete!(ExpiringCaches.getcache(getAlbum), (id,))
    return album
end

function deleteAlbum(id)
    Mapper.delete(id)
    delete!(ExpiringCaches.getcache(getAlbum), (id,))
    return
end

function pickAlbumToListen()
    albums = Mapper.getAllAlbums()
    leastTimesPicked = minimum(x->x.timespicked, albums)
    leastPickedAlbums = filter(x->x.timespicked == leastTimesPicked, albums)
    pickedAlbum = rand(leastPickedAlbums)
    pickedAlbum.timespicked += 1
    Mapper.update(pickedAlbum)
    delete!(ExpiringCaches.getcache(getAlbum), (pickedAlbum.id,))
    return pickedAlbum
end

end # module