module Service

using Dates
using ..Model, ..Mapper

function createAlbum(obj)
    @assert haskey(obj, :name) && !isempty(obj.name)
    @assert haskey(obj, :artist) && !isempty(obj.artist)
    @assert haskey(obj, :songs) && !isempty(obj.songs)
    @assert haskey(obj, :year) && 1900 < obj.year < Dates.year(Dates.now())
    album = Album(obj.name, obj.artist, obj.year, obj.songs)
    Mapper.store!(album)
    return album
end

getAlbum(id) = Mapper.get(id)

function updateAlbum(id, updated)
    album = Mapper.get(id)
    album.name = updated.name
    album.artist = updated.artist
    album.year = updated.year
    album.songs = updated.songs
    Mapper.store!(album)
    return album
end

function deleteAlbum(id)
    Mapper.delete(id)
    return
end

function pickAlbumToListen()
    albums = Mapper.getAllAlbums()
    leastTimesPicked = minimum(x->x.timespicked, albums)
    leastPickedAlbums = filter(x->x.timespicked == leastTimesPicked, albums)
    pickedAlbum = rand(leastPickedAlbums)
    pickedAlbum.timespicked += 1
    Mapper.store!(pickedAlbum)
    return pickedAlbum
end

end # module