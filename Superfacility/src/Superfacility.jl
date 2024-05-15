module Superfacility
module SFAPI

include("data.jl")
using .Data

include("error.jl")
using .Error

include("token.jl")
using .Token

include("query.jl")
using .Query

include("account.jl")
using .Account

include("ls.jl")
using .Ls

include("executable.jl")
using .Executable

include("status.jl")
using .Status

end # module SFAPI
end
