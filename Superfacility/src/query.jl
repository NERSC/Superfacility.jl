module Query

using JSON
using HTTP
using URIs
using ResultTypes

using ..Token
using ..Error
using ..Data

const scheme = "https"
const host   = "api.nersc.gov"

function generate_uri(
        path::String; parameters::Dict{String, T} = Dict{String, Any}()
    )::URI where T <: Any

    URIs.URI(;
        scheme=scheme, host=host,
        path  = "/api/v1.2/$(path)", 
        query = parameters
    )
end

function process_response(
        resp::HTTP.Messages.Response
    )::Result{Union{Vector{Any}, Dict{Symbol, Any}}, HTTPException}

    if resp.status == 200
        return parse_response(resp)
    end

    return HTTPException(resp.status, String(resp.body))
end

function get(
        path::String, api_token::AccessToken; 
        parameters::Dict{String, T} = Dict{String, Any}()
    )::Result{Union{Vector{Any}, Dict{Symbol, Any}}, HTTPException} where T <: Any

    uri  = generate_uri(path; parameters=parameters)
    resp = HTTP.get(
        uri, [
            "accept" => "application/json",
            "Authorization" => "$(api_token.token_type) $(api_token.access_token)"
        ]; status_exception=false
    )

    process_response(resp)
end

function get(
        path::String; parameters::Dict{String, T} = Dict{String, Any}()
    )::Result{Union{Vector{Any}, Dict{Symbol, Any}}, HTTPException} where T <: Any

    uri  = generate_uri(path; parameters=parameters)
    resp = HTTP.get(
        uri, [
            "accept" => "application/json",
        ]; status_exception=false
    )

    process_response(resp)
end

function post(
        path::String, data::String, api_token::AccessToken; 
        parameters::Dict{String, T} = Dict{String, Any}()
    )::Result{Union{Vector{Any}, Dict{Symbol, Any}}, HTTPException} where T <: Any

    uri  = generate_uri(path; parameters=parameters)
    resp = HTTP.post(
        uri, [
            "accept" => "application/json",
            "Authorization" => "$(api_token.token_type) $(api_token.access_token)",
            "Content-Type" => "application/x-www-form-urlencoded"
        ], data; status_exception=false
    )

    process_response(resp)
end

end