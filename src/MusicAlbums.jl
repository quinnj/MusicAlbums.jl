module MusicAlbums

export Model, Mapper, Service, Resource, Client

include("ConnectionPools.jl")
using .ConnectionPools

include("Workers.jl")
using .Workers

include("Model.jl")
using .Model

include("Auth.jl")
using .Auth

include("Contexts.jl")
using .Contexts

include("Mapper.jl")
using .Mapper

include("Service.jl")
using .Service

include("Resource.jl")
using .Resource

include("Client.jl")
using .Client

function run(dbfile, authkeysfile)
    Workers.init()
    Mapper.init(dbfile)
    Auth.init(authkeysfile)
    Resource.run()
end

end # module
