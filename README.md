# Hello Elixir

A demonstration Elixir project showcasing third-party dependencies using `mix`.
It is the Elixir/Mix counterpart of the sibling `hello_erlang` (Erlang/rebar3) project.

## Features
- **JSON Handling**: Uses `jason`.
- **Logging**: Uses the built-in `Logger`.
- **HTTP Client**: Includes `httpoison` (which wraps `hackney`).
- **JWS Signing**: Uses `jose` to sign the greeting as a JSON Web Signature.
- **Testing**: Uses `ExUnit` with doctests, `mox` for mocking the HTTP client, and a local
  `plug_cowboy` server for one end-to-end test.
- **Dev tooling**: `credo` (lint), `ex_doc` (docs), and `ymlr` (the `mix hello.manifest` task).

## Dependency scopes

Mix has no separate dev/prod dependency sections. Each entry in `mix.exs` carries an
`only:` option that limits it to one or more environments, and `runtime: false` keeps
build-time tools out of the application start list.

| Scope | Packages | Available when |
|---|---|---|
| prod (all envs) | `jason`, `httpoison`, `jose` | always, including releases |
| dev only | `credo`, `ex_doc`, `ymlr` | `MIX_ENV=dev` |
| test only | `mox`, `plug_cowboy` | `MIX_ENV=test` |

`mix deps.tree --only prod` shows what actually ships. Every dependency is fetched and
recorded in `mix.lock` regardless of scope.

## Deliberately vulnerable dependencies

This project exists to demonstrate the dependably vulnerability scanner, so one package in
each scope is pinned to a release with a published advisory. Nothing in the project calls
the affected code paths. Do not "fix" these pins without also updating this table.

| Scope | Package | Advisory | Fixed in |
|---|---|---|---|
| prod | `jose 1.11.6` | CVE-2023-50966 / GHSA-9mg4-v392-8j68, DoS via a large PBES2 `p2c` value | 1.11.7 |
| dev | `ymlr 5.1.5` | CVE-2026-65636, YAML injection via unescaped newlines in comments | 5.1.6 |
| test | `plug_cowboy 2.8.0` | CVE-2026-32688 / GHSA-q8x4-x7mp-5vg2, atom table exhaustion via HTTP/2 `:scheme` | 2.8.1 |

`hackney 1.25.0`, pulled in by `httpoison`, also carries several 2026 advisories. That one is
incidental: every hackney 1.x is affected and the fix is only in hackney 4.x, which needs
`httpoison ~> 3.0`.

The first choice for the dev scope was `earmark`, which is retired on Hex. The registry
refused it outright with `Blocked by policy (Deprecated)`, which is itself a useful thing to
see the registry do.

Hex's own audit shows the same findings:

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

### 6. Lint and Docs (dev only)
```bash
MIX_ENV=dev mix credo --strict
MIX_ENV=dev mix docs
MIX_ENV=dev mix hello.manifest   # writes deps-manifest.yaml
```

### 7. Run the Demo
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
- `lib/`: Source code (`.ex` files); `lib/mix/tasks/` holds the dev-only Mix task
- `config/`: Runtime config; tests swap the HTTP client for a Mox mock here
- `test/`: Test suites (`.exs` files using ExUnit)
- `mix.exs`: Project configuration and dependencies
- `mix.lock`: Locked dependency versions and checksums
- `dependably_public_key.pem`: Pinned signing key of the private registry
