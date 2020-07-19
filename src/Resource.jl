module Resource

using HTTP

const ROUTER = HTTP.Router()

createAlbum(req) = Service.createAlbum(JSON3.read(req.body))::Album
HTTP.@register(ROUTER, "POST", "/album", createAlbum)

getAlbum(req) = Service.getAlbum(parse(Int, HTTP.URIs.splitpath(req.target)[2]))::Album
HTTP.@register(ROUTER, "GET", "/album/*", getAlbum)

updateAlbum(req) = Service.updateAlbum(parse(Int, HTTP.URIs.splitpath(req.target)[2]), JSON3.read(req.body, Album))::Album
HTTP.@register(ROUTER, "PUT", "/album/*", updateAlbum)

deleteAlbum(req) = Service.deleteAlbum(parse(Int, HTTP.URIs.splitpath(req.target)[2]))
HTTP.@register(ROUTER, "DELETE", "/album/*", deleteAlbum)

pickAlbumToListen(req) = Service.pickAlbumToListen()::Album
HTTP.@register(ROUTER, "GET", "/", pickAlbumToListen)

end # module