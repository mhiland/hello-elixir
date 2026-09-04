defmodule HelloWorld.Fetcher do
  @moduledoc """
  Fetches a greeting document, as produced by `HelloWorld.greet/1`, over HTTP.
  """

  @doc """
  GETs `url` and decodes the JSON greeting in the response body.

  The HTTP client comes from the `:http_client` application env unless a
  `:client` option is given.
  """
  @spec fetch_greeting(String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def fetch_greeting(url, opts \\ []) when is_binary(url) do
    client =
      Keyword.get_lazy(opts, :client, fn -> Application.fetch_env!(:hello_world, :http_client) end)

    with {:ok, %{status: 200, body: body}} <- client.get(url),
         {:ok, %{"name" => _} = greeting} <- Jason.decode(body) do
      {:ok, greeting}
    else
      {:ok, %{status: status}} -> {:error, {:unexpected_status, status}}
      {:ok, _not_a_greeting} -> {:error, :not_a_greeting}
      {:error, %Jason.DecodeError{}} -> {:error, :invalid_json}
      {:error, reason} -> {:error, reason}
    end
  end
end
