module Resource

using Dates, HTTP, JSON3
using ..Model, ..Service

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

function requestHandler(req)
    start = Dates.now(Dates.UTC)
    @info (timestamp=start, event="ServiceRequestBegin", tid=Threads.threadid(), method=req.method, target=req.target)
    local resp
    try
        obj = HTTP.handle(ROUTER, req)
        resp = HTTP.Response(200, JSON3.write(obj))
    catch e
        s = IOBuffer()
        showerror(s, e, catch_backtrace(); backtrace=true)
        errormsg = String(resize!(s.data, s.size))
        @error errormsg
        resp = HTTP.Response(500, errormsg)
    end
    stop = Dates.now(Dates.UTC)
    @info (timestamp=stop, event="ServiceRequestEnd", tid=Threads.threadid(), method=req.method, target=req.target, duration=Dates.value(stop - start), status=resp.status, bodysize=length(resp.body))
    return resp
end

function run()
    HTTP.serve(requestHandler, "0.0.0.0", 8080)
end

end # module