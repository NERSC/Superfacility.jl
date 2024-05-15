module Account

import ResultTypes

using Base: @kwdef

@kwdef struct User
    workphone::String
    name::String
    middlename::String
    lastname::String
    firstname::String
    email::String
    otherPhones::String
    uid::Int64
end

function User(d::ResultTypes.Result)
    User(;ResultTypes.unwrap(d)...)
end

export User

end