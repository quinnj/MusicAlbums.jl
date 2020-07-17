module Client

using HTTP, JSON3

const SERVER = Ref{String}("http://localhost:8080")

function createAlbum(name, artist, year, songs)
    body = (; name, artist, year, songs)
    resp = HTTP.post(string(SERVER[], "/album"), [], JSON3.write(body))
    return JSON3.read(resp.body)
end

function getAlbum(id)
    resp = HTTP.get(string(SERVER[], "/album/$id"))
    return JSON3.read(resp.body)
end

function updateAlbum(album)
    resp = HTTP.post(string(SERVER[], "/album/$(album.id)"), [], JSON3.write(album))
    return JSON3.read(resp.body)
end

function deleteAlbum(id)
    resp = HTTP.delete(string(SERVER[], "/album/$id"))
    return
end

function pickAlbumToListen()
    resp = HTTP.delete(string(SERVER[], "/"))
    return JSON3.read(resp.body)
end

end # module