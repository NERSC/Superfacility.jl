module Ls

import ResultTypes

using Base: @kwdef

@kwdef struct DirEntry
    group::String
    user::String
    name::String
    perms::String
    hardlinks::Int64
    size::Float64
    date::String
end

Base.convert(::Type{DirEntry}, e::Dict{Symbol, Any}) = DirEntry(;e...)

@kwdef struct Dir
    status::String
    entries::Vector{DirEntry}
    error::Union{String, Nothing}
end

function Dir(d::ResultTypes.Result)
    Dir(;ResultTypes.unwrap(d)...)
end

export DirEntry, Dir

end