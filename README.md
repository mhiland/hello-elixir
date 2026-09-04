# Hello Elixir

A demonstration Elixir project showcasing third-party dependencies using `mix`.
It is the Elixir/Mix counterpart of the sibling `hello_erlang` (Erlang/rebar3) project.

## Features
- **JSON Handling**: Uses `jason`.
- **Logging**: Uses the built-in `Logger`.
- **HTTP Client**: Includes `httpoison` (which wraps `hackney`).
- **JWS Signing**: Uses `jose` to sign the greeting as a JSON Web Signature.
- **Testing**: Uses `ExUnit`, including doctests.

## Deliberately vulnerable dependency

`jose` is pinned to exactly `1.11.6`, a release with a published advisory
(CVE-2023-50966 / GHSA-9mg4-v392-8j68, a denial of service via a large PBES2 `p2c`
value, fixed in 1.11.7). This is intentional: the project exists to demonstrate the
dependably vulnerability scanner, and this pin gives it something to catch. Nothing in
the project calls the affected PBES2 code path. Do not "fix" the pin without also
updating this note. Hex's own audit shows the same finding:

```bash
mix hex.audit
```

## Prerequisites

You will need Erlang/OTP and Elixir installed on your machine. `mix` ships with Elixir.

### macOS
```bash
brew install elixir
```

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install elixir
```

### Windows
The easiest way is via [Chocolatey](https://chocolatey.org/):
```powershell
choco install elixir
```

## Getting Started

### 1. Install the Hex and rebar3 build tools
Hex is Mix's package manager and rebar3 is needed to build the Erlang dependencies.
Both are tools, not packages, and are installed once per user:

```bash
mix local.hex --force
mix local.rebar --force
```

### 2. Configure the private registry
All Hex packages are pulled from the private dependably registry (`https://dependably.northwardlabs.ca/hex`).
Unlike rebar3, Mix keeps repo definitions in the per-user `~/.hex/hex.config` rather than in
the project, so every dependency in `mix.exs` names the repo explicitly with `repo: "dependably"`.
The registry's signing key is pinned in `dependably_public_key.pem`. The registry requires a
token, which is kept out of the repository. Register the repo once per user:

```bash
mix hex.repo add dependably https://dependably.northwardlabs.ca/hex \
  --public-key dependably_public_key.pem \
  --auth-key YOUR_TOKEN
```

CI does this itself from the shared `REGISTRY_URL` / `REGISTRY_KEY` variables.

### 3. Install Dependencies
Navigate to the project root and run:
```bash
mix deps.get
```

### 4. Compile the Project
```bash
mix compile
```

### 5. Run Tests
Verify the project is working correctly using the ExUnit test suite:
```bash
mix test
```

### 6. Run the Demo
You can run the demo module directly:
```bash
mix run -e 'HelloWorld.Demo.run()'
```

Or start an interactive shell with the project loaded:
```bash
iex -S mix
```

Once inside `iex`, run:
```elixir
HelloWorld.Demo.run()
```

## Project Structure
- `lib/`: Source code (`.ex` files)
- `test/`: Test suites (`.exs` files using ExUnit)
- `mix.exs`: Project configuration and dependencies
- `mix.lock`: Locked dependency versions and checksums
- `dependably_public_key.pem`: Pinned signing key of the private registry
