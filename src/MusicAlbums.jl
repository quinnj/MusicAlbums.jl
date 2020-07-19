module MusicAlbums

export Model, Mapper, Service, Resource, Client

include("Model.jl")
using .Model

include("Mapper.jl")
using .Mapper

include("Service.jl")
using .Service

include("Resource.jl")
using .Resource

include("Client.jl")
using .Client

function run()
    Resource.run()
end

end # module
