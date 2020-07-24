module ConnectionPools

export withconnection

macro v1_3(expr, elses=nothing)
    esc(quote
        @static if VERSION >= v"1.3"
            $expr
        else
            $elses
        end
    end)
end

mutable struct Pod{T}
    conns::Channel{T}
    numactive::Int
    max::Int
    idle::Int
    reuse::Int
    new::Base.Callable
end

mutable struct Connection{T}
    conn::T
    pod::Pod{Connection{T}}
    idle::Float64
    count::Int
end

Pod(T, max, idle, reuse, new) = Pod(Channel{Connection{T}}(Inf), 0, max, idle, reuse, new)

function decr!(pod::Pod)
    @v1_3 @assert(islocked(pod.conns.cond_take))
    pod.numactive -= 1
    return
end

function incr!(pod::Pod)
    @v1_3 @assert(islocked(pod.conns.cond_take))
    pod.numactive += 1
    return
end

function Base.acquire(pod::Pod, args...; kw...)
    @v1_3 lock(pod.conns)
    try
        while isready(pod.conns)
            conn = take!(pod.conns)
            if (time() - conn.idle) > pod.idle
                close(conn.conn)
            elseif conn.count >= pod.reuse
                close(conn.conn)
            elseif !isopen(conn.conn)
                close(conn.conn)
            else
                conn.count += 1
                incr!(pod)
                return conn
            end
        end
        # If there are not too many connections, create new
        if pod.numactive < pod.max
            incr!(pod)
            return Connection(pod.new(args...; kw...), pod, time(), 1)
        end
        # otherwise, wait for a connection to be released
        while true
            conn = take!(pod.conns)
            if (time() - conn.idle) > pod.idle
                close(conn.conn)
            elseif conn.count >= pod.reuse
                close(conn.conn)
            elseif !isopen(conn.conn)
                close(conn.conn)
            else
                conn.count += 1
                incr!(pod)
                return conn
            end
            if pod.numactive < pod.max
                incr!(pod)
                return Connection(pod.new(args...; kw...), pod, time(), 1)
            end
        end
    finally
        @v1_3 unlock(pod.conns)
    end
end

function Base.release(conn::Connection)
    pod = conn.pod
    @v1_3 lock(pod.conns)
    try
        decr!(pod)
        conn.idle = time()
        put!(conn.pod.conns, conn)
    finally
        @v1_3 unlock(pod.conns)
    end
    return
end

function withconnection(f, pod::Pod, args...; kw...)
    conn = Base.acquire(pod, args...; kw...)
    try
        return f(conn.conn)
    finally
        Base.release(conn)
    end
end

struct Pool{K, C}
    lock::ReentrantLock
    pods::Dict{K, Pod{Connection{C}}}
    max::Int
    idle::Int
    reuse::Int
    new::Base.Callable
end

Pool(K, C, max, idle, reuse, new) = Pool{K, C}(ReentrantLock(), Dict{K, Pod{Connection{C}}}(), max, idle, reuse, new)
Pod(pool::Pool{K, C}) where {K, C} = Pod(C, pool.max, pool.idle, pool.reuse, pool.new)

function Base.acquire(pool::Pool{K, C}, key, args...; kw...) where {K, C}
    pod = lock(pool.lock) do
        get!(() -> Pod(pool), pool.pods, key)
    end
    return Base.acquire(pod, key, args...; kw...)
end

function withconnection(f, pool::Pool, key, args...; kw...)
    pod = lock(pool.lock) do
        get!(() -> Pod(pool), pool.pods, key)
    end
    return withconnection(f, pod, key, args...; kw...)
end

end # module
