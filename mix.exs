defmodule HelloWorld.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_world,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Every Hex package comes from the private dependably registry, which is
  # registered under the repo name "dependably" (see README.md). Mix's Hex
  # client, unlike rebar3, keeps repo definitions (URL, signing key, token) in
  # the per-user ~/.hex/hex.config rather than in the project, so each dep
  # names the repo explicitly here. The name must be exactly "dependably": the
  # registry signs every resource under that name and Hex verifies it on each
  # fetch. The org's signing key is pinned in dependably_public_key.pem so a
  # fetch is verified against a key committed with the code rather than one
  # downloaded at build time.
  #
  # No credential lives here. The token goes in ~/.hex/hex.config via
  # `mix hex.repo add`; CI writes it from the shared REGISTRY_KEY variable
  # (see .gitlab-ci.yml).
  #
  # Scopes: deps without `only:` ship in every env including prod releases.
  # `only: :dev` / `only: :test` deps are fetched and locked in every env but
  # excluded from the tree elsewhere; `runtime: false` keeps build-time tools
  # out of the application start list.
  #
  # Three deps are deliberately pinned to releases with published advisories,
  # one per scope, so the dependably vulnerability scanner has something to
  # catch in each. Exact pins keep `mix deps.update` from quietly moving off
  # them. See "Deliberately vulnerable dependencies" in README.md.
  defp deps do
    [
      # --- prod (every env) ---
      {:jason, "~> 1.4", repo: "dependably"},
      {:httpoison, "~> 2.2", repo: "dependably"},
      # VULNERABLE ON PURPOSE (prod): CVE-2023-50966 / GHSA-9mg4-v392-8j68,
      # denial of service via a large PBES2 p2c value, fixed in 1.11.7.
      # Nothing here uses the affected PBES2 path.
      {:jose, "== 1.11.6", repo: "dependably"},

      # --- dev only ---
      {:credo, "~> 1.7", only: :dev, runtime: false, repo: "dependably"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false, repo: "dependably"},
      # VULNERABLE ON PURPOSE (dev): EEF-CVE-2026-65636 / CVE-2026-65636, YAML
      # injection via unescaped newlines in document comments, fixed in 5.1.6.
      # Only used by the `mix hello.manifest` dev task. (earmark was the first
      # choice, but the registry blocks it: "Blocked by policy (Deprecated)".)
      {:ymlr, "== 5.1.5", only: :dev, runtime: false, repo: "dependably"},

      # --- test only ---
      {:mox, "~> 1.3", only: :test, repo: "dependably"},
      # VULNERABLE ON PURPOSE (test): GHSA-q8x4-x7mp-5vg2 / CVE-2026-32688,
      # atom table exhaustion via the HTTP/2 :scheme pseudo-header, fixed in
      # 2.8.1. Only serves the local HTTP/1.1 test server in fetcher tests.
      {:plug_cowboy, "== 2.8.0", only: :test, repo: "dependably"}
    ]
  end
end
