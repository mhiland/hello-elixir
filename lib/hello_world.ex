defmodule HelloWorld do
  @moduledoc """
  Builds a greeting for a name and encodes it as JSON.

  The Elixir counterpart of the `hello_world` module in the sibling
  `hello_erlang` project.
  """

  @doc """
  Returns a JSON string greeting `name`.

  ## Examples

      iex> HelloWorld.greet("Claude")
      ~s({"name":"Claude","status":"success"})

  """
  @spec greet(String.t()) :: String.t()
  def greet(name) when is_binary(name) do
    encode_message(%{name: name, status: "success"})
  end

  @doc "Encodes `map` as a JSON string."
  @spec encode_message(map()) :: String.t()
  def encode_message(map) when is_map(map) do
    Jason.encode!(map)
  end
end
