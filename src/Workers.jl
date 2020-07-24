module Workers

const WORK_QUEUE = Channel{Task}(0)

macro async(thunk)
    esc(quote
        tsk = @task $thunk
        tsk.storage = current_task().storage
        put!(Workers.WORK_QUEUE, tsk)
        tsk
    end)
end

function init()
    tids = Threads.nthreads() == 1 ? (1:1) : 2:Threads.nthreads()
    Threads.@threads for tid in 1:Threads.nthreads()
        if tid in tids
            Base.@async begin
                for task in WORK_QUEUE
                    schedule(task)
                    wait(task)
                end
            end
        end
    end
    return
end

end # module