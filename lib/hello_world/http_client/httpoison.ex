defmodule HelloWorld.HTTPClient.HTTPoison do
  @moduledoc "`HelloWorld.HTTPClient` implemented with HTTPoison."

  @behaviour HelloWorld.HTTPClient

  @impl true
  def get(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:ok, %{status: status, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
