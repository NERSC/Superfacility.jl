module Executable

using JSON

import ResultTypes

using Base: @kwdef

using ..Token
using ..Query

@kwdef struct Command
    status::String
    task_id::String
    error::Union{String, Nothing}
end

function Command(d::ResultTypes.Result)
    Command(;ResultTypes.unwrap(d)...)
end

@kwdef struct Result
    status::String
    output::Union{String, Nothing} = nothing
    error::Union{String, Nothing} = nothing
end

@kwdef struct Task
    result::Union{Nothing, Result}
    status::String
    id::String
end

Base.convert(::Type{Result}, e::Dict{Symbol, Any}) = Result(;e...)
Base.convert(::Type{Result}, e::String) = Result(;JSON.parse(
    e; dicttype=Dict{Symbol, Any}
)...)

function result(cmd::Command, tc::Token.AccessTokenContainer; sleep_time=1)
    function result_wroker()::Result
        while true
            tc = Token.refresh(tc)
            task = Task(;
                ResultTypes.unwrap(
                    Query.get("tasks/$(cmd.task_id)", tc.token)
                )...
            )
            if task.status == "completed"
                return task.result
            end
            sleep(sleep_time)
        end
    end

    @async result_wroker()
end

export result, Command

function run(cmd_str::String, tc::Token.AccessTokenContainer)
    Command(
        Query.post(
            "utilities/command/perlmutter", 
            "executable=$(cmd_str)",
            tc.token
        )
    )
end

export run

end