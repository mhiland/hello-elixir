defmodule HelloWorld.FetcherIntegrationTest do
  # Runs the real HTTPoison client against a local Plug.Cowboy server, so the
  # whole path from socket to decoded greeting is exercised once.
  use ExUnit.Case, async: false

  alias HelloWorld.Fetcher
  alias HelloWorld.HTTPClient

  defmodule GreetingRouter do
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    get "/greet/:name" do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, HelloWorld.greet(name))
    end

    match _ do
      send_resp(conn, 404, "not found")
    end
  end

  setup_all do
    {:ok, _pid} = Plug.Cowboy.http(GreetingRouter, [], port: 0, ref: __MODULE__)
    on_exit(fn -> Plug.Cowboy.shutdown(__MODULE__) end)
    {:ok, base_url: "http://127.0.0.1:#{:ranch.get_port(__MODULE__)}"}
  end

  test "fetches a greeting end to end", %{base_url: base_url} do
    assert {:ok, %{"name" => "Ada", "status" => "success"}} =
             Fetcher.fetch_greeting("#{base_url}/greet/Ada", client: HTTPClient.HTTPoison)
  end

  test "surfaces a 404 from the server", %{base_url: base_url} do
    assert {:error, {:unexpected_status, 404}} =
             Fetcher.fetch_greeting("#{base_url}/missing", client: HTTPClient.HTTPoison)
  end
end
