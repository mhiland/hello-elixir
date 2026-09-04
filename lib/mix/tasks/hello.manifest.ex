defmodule Mix.Tasks.Hello.Manifest do
  @shortdoc "Writes the locked dependencies to deps-manifest.yaml (dev only)"

  @moduledoc """
  Writes every entry in `mix.lock` to `deps-manifest.yaml` as YAML, via Ymlr.

  Ymlr is a `:dev`-only dependency, so the compiler is told not to warn about
  it being undefined in prod and test compiles.
  """

  use Mix.Task

  alias Mix.Dep.Lock

  @compile {:no_warn_undefined, Ymlr}

  @impl true
  def run(_args) do
    unless Code.ensure_loaded?(Ymlr) do
      Mix.raise("Ymlr is only available in MIX_ENV=dev")
    end

    deps =
      Lock.read()
      |> Enum.sort()
      |> Enum.map(fn {name, lock} -> %{name: Atom.to_string(name), version: version(lock)} end)

    yaml = Ymlr.document!(%{app: "hello_world", dependencies: deps})
    File.write!("deps-manifest.yaml", yaml)
    Mix.shell().info("Wrote deps-manifest.yaml (#{length(deps)} dependencies)")
  end

  defp version(lock) when is_tuple(lock) and tuple_size(lock) >= 3, do: elem(lock, 2)
  defp version(_), do: "unknown"
end
