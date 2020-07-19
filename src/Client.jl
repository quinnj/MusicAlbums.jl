module Client

using HTTP, JSON3
using ..Model

const SERVER = Ref{String}("http://localhost:8080")

function createAlbum(name, artist, year, songs)
    body = (; name, artist, year, songs)
    resp = HTTP.post(string(SERVER[], "/album"), [], JSON3.write(body))
    return JSON3.read(resp.body, Album)
end

function getAlbum(id)
    resp = HTTP.get(string(SERVER[], "/album/$id"))
    return JSON3.read(resp.body, Album)
end

function updateAlbum(album)
    resp = HTTP.put(string(SERVER[], "/album/$(album.id)"), [], JSON3.write(album))
    return JSON3.read(resp.body, Album)
end

function deleteAlbum(id)
    resp = HTTP.delete(string(SERVER[], "/album/$id"))
    return
end

function pickAlbumToListen()
    resp = HTTP.get(string(SERVER[], "/"))
    return JSON3.read(resp.body, Album)
end

end # module