# SFAPI.jl

Julia Client for the NERSC Superfacilty API. The Julia client is currently under
active development, and therefore might change a bit more. It's based on
`v1.2`: of the [Superfacility API](https://docs.nersc.gov/services/sfapi/).

It largely follows the [Python Client](https://github.com/NERSC/sfapi_client).

## Example usage

Take a look at `examples/` for several example notebooks. These also cover all
the convenience functions implemented so far. The basic usage looks as follows:

### Credentials and Token

Store the `clientid.txt`, and `priv_key.pem` from
[Iris](https://iris.nersc.gov/) in the same folder (which is not publically
accessible). The create a token container as follows:
```julia
using Superfacilty: SFAPI
using ResultTypes

client = SFAPI.Token.Client("/path/to/credentials"))
token_container = SFAPI.Token.fetch(client) |> unwrap
```
The token container can be refreshed using:
```julia
token_container = SFAPI.Token.refresh(token_container)
```

### Making API Queries

Low-level queries are made using `SFAPI.Query.get` and `SFAPI.Query.post`. Eg.
```julia
SFAPI.Query.get("account", token_container.token)
```
requests user account data. Note that the second argument is optional for public
API endpoints.

### Running functions remotely

`Executable.run` and `Executable.result` use the API to remotely run a command
(as your user account corresponding to the client token). A command is run
asynchronously -- that is to say `run` _starts_ a process, and `result` starts a
Julia async taks which keeps checking the output fromt he process. For example:
```julia
cmd = SFAPI.Executable.run("ls $(home_path)", token_container)
t = SFAPI.Executable.result(cmd, token_container)
while ! istaskdone(t)
    println("Wating for result ...")
    sleep(1)
end
```
This is how you would repeatedly poll the SFAPI to check if the command is done
running. `SFAPI.Executable.result` does repeatedly check the status, and fetches
the result when done (continuously refreshing the API token). So progress is
made even when not checking `istaskdone`.