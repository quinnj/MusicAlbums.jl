module Resource

using HTTP

const ROUTER = HTTP.Router()

HTTP.@register(ROUTER, "POST", "/album", createAlbum)
HTTP.@register(ROUTER, "GET", "/album/*", getAlbum)
HTTP.@register(ROUTER, "PUT", "/album/*", updateAlbum)
HTTP.@register(ROUTER, "DELETE", "/album/*", deleteAlbum)
HTTP.@register(ROUTER, "GET", "/", pickAlbumToListen)

end # module