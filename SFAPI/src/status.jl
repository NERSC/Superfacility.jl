module Status

import ResultTypes

using Base: @kwdef

@kwdef struct StatusEntry
    name::String
    full_name::String
    description::String
    system_type::String
    notes::Vector{String}
    status::String
    updated_at::String
end

StatusEntry(d::ResultTypes.Result) = StatusEntry(;ResultTypes.unwrap(d)...)

const CenterStatus = Vector{StatusEntry}
Vector{StatusEntry}(d::ResultTypes.Result) = CenterStatus(ResultTypes.unwrap(d))

Base.convert(::Type{StatusEntry}, e::Dict{Symbol, Any}) = StatusEntry(;e...)

export CenterStatus, StatusEntry

end