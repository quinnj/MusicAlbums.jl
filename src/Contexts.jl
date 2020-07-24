module Contexts

export withcontext, getuser

using ..Model

mutable struct Context
    user::User
end

function withcontext(f, user::User)
    task_local_storage(:CONTEXT, Context(user)) do
        f()
    end
end

function getuser()
    if haskey(task_local_storage(), :CONTEXT)
        return task_local_storage(:CONTEXT).user
    else
        throw(ArgumentError("no valid context set"))
    end
end

end # module