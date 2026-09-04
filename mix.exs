defmodule HelloWorld.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_world,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
  defp deps do
    [
      {:jason, "~> 1.4", repo: "dependably"},
      {:httpoison, "~> 2.2", repo: "dependably"},
      # Deliberately pinned to a release with a known, published advisory
      # (CVE-2023-50966 / GHSA-9mg4-v392-8j68: denial of service via a large
      # PBES2 p2c value, fixed in 1.11.7) so the dependably vulnerability
      # scanner has something to catch. The exact pin keeps `mix deps.update`
      # from quietly moving off it. Nothing here uses the affected PBES2 path.
      {:jose, "== 1.11.6", repo: "dependably"}
    ]
  end
end
