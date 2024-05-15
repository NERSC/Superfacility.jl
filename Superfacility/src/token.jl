module Token

using JSON
using JSONWebTokens
using HTTP
using URIs
using Dates
using TimeZones
using Chain
using ResultTypes

using Base: @kwdef

using ..Error
using ..Data

struct Client
    id::String
    key_file::String

    function Client(path::String)
        client_id = open(joinpath(path, "clientid.txt"), "r") do f
           read(f, String)
        end

        new(client_id, joinpath(path, "priv_key.pem"))
    end
end

export Client

const token_uri = uri = URIs.URI(;
    scheme="https",
    host="oidc.nersc.gov",
    path="/c2id/token"
)

@kwdef struct JWTClaimsSet
    iss::String
    sub::String
    aud::String
    exp::Int64
    iat::Int64
end

@kwdef struct AccessToken
    access_token::String
    scope::String
    token_type::String
    expires_in::Int64
end

struct AccessTokenContainer
    client::Client
    token::AccessToken
    iat::Int64
end

export AccessToken, AccessTokenContainer

epoch_utc(dt) = @chain dt begin
    ZonedDateTime(_, tz"America/Los_Angeles")
    astimezone(_, tz"UTC")
    DateTime(_)
    datetime2unix(_)
    floor(Int, _)
end

function fetch(client::Client)::Result{AccessTokenContainer, HTTPException}
    fetch_time = epoch_utc(now())
    
    jwt_payload = JWTClaimsSet(
        iss=client.id, sub=client.id, aud=string(token_uri),
        iat=fetch_time, exp=epoch_utc(now() + Dates.Minute(10))
    )

    encoding = JSONWebTokens.RS256(client.key_file)
    jwt = JSONWebTokens.encode(encoding, JSON.json(jwt_payload))

    uri = URIs.URI(;
        scheme="https",
        host="oidc.nersc.gov",
        path="/c2id/token",
        query=Dict(
            "client_assertion_type" => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
            "client_assertion" => jwt,
            "grant_type" => "client_credentials"
        )
    )

    resp = HTTP.post(
        uri, [
            "Content-Type" => "application/x-www-form-urlencoded"
        ]; status_exception=false
    )

    if resp.status == 200
        return AccessTokenContainer(
            client,
            AccessToken(;parse_response(resp)...),
            fetch_time
        )
    end

    return HTTPException(resp.status, String(resp.body))
end

function refresh(tc::AccessTokenContainer)
    if tc.iat + tc.token.expires_in > epoch_utc(now())
        return tc
    end

    return unwrap(fetch(tc.client))
end

end