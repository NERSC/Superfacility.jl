module Data

using JSON
using HTTP

parse_response(resp::HTTP.Messages.Response) = JSON.parse(
    String(resp.body); dicttype=Dict{Symbol, Any}
)

export parse_response

end