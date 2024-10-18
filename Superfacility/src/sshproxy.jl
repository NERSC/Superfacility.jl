module SshProxy

using HTTP
using JSON
using Base64
using ArgParse

const KEY_PAIR_URL = "https://sshproxy.nersc.gov/create_pair/default/"
const COLLAB_URL = "https://sshproxy.nersc.gov/create_pair/collab/"

function get_key(username::Union{Nothing, String}, collab::Union{Nothing, String})
    url, data, key_name = if isnothing(collab)
        (KEY_PAIR_URL, Dict(), "nersc")
    else
        (COLLAB_URL, Dict("target_user" => collab), collab)
    end

    username = username === nothing ? ENV["USER"] : username

    passwd = Base.getpass("Password+OTP")
    user_pw = read(passwd, String)

    keypath = joinpath(ENV["HOME"], ".ssh")
    private = joinpath(keypath, key_name)
    public = joinpath(keypath, "$key_name.pub")
    pub_cert = joinpath(keypath, "$key_name-cert.pub")

    isfile(private) && rm(private)
    isfile(public) && rm(public)

    res = HTTP.post(url, body=JSON.json(data),
        headers=Dict("Content-Type" => "Application/json", "Authorization" => "Basic $(Base64.base64encode("$username:$user_pw"))"))
    Base.shred!(passwd)

    if res.status != 200
        throw(ErrorException("Failed to get key: $(res.status)"))
    end
    
    out = String(res.body)
    pub_index = findfirst("ssh-rsa-cert-v01", out)

    if pub_index === nothing
        throw(ErrorException("Invalid response from server"))
    end

    key_sep = "-----END RSA PRIVATE KEY-----\n"
    private_key, pub_key = split(out, key_sep)
    private_key = string(private_key, key_sep)

    # Write the files
    open(pub_cert, "w") do f
        write(f, pub_key)
    end
    open(private, "w") do f
        write(f, private_key)
    end
    chmod(private, 0o600)

    public_pem = read(`ssh-keygen -y -f $private`, String)
    open(public, "w") do f
        write(f, public_pem)
    end

end

function sshproxy()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--username"
        "--collab"
    end

    parsed_args = parse_args(s)
    username = get(parsed_args, "username", nothing)
    collab = get(parsed_args, "collab", nothing)

    try
        get_key(username, collab)
    catch e
	rethrow(e)
        exit(1)
    end
    exit(0)
end

export sshproxy

end
