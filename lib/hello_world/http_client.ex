defmodule HelloWorld.HTTPClient do
  @moduledoc """
  The minimal HTTP client contract `HelloWorld.Fetcher` depends on.

  Keeping this as a behaviour lets tests substitute a Mox mock for the real
  `HelloWorld.HTTPClient.HTTPoison` implementation.
  """

  @type response :: %{status: non_neg_integer(), body: binary()}

  @callback get(url :: String.t()) :: {:ok, response()} | {:error, term()}
end
