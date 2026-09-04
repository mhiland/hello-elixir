defmodule HelloWorld.FetcherTest do
  use ExUnit.Case, async: true

  import Mox

  alias HelloWorld.Fetcher
  alias HelloWorld.HTTPClient.Mock

  setup :verify_on_exit!

  @url "http://greetings.example/claude"

  test "returns the decoded greeting on a 200 with a JSON body" do
    expect(Mock, :get, fn @url -> {:ok, %{status: 200, body: HelloWorld.greet("Claude")}} end)

    assert {:ok, %{"name" => "Claude", "status" => "success"}} = Fetcher.fetch_greeting(@url)
  end

  test "reports an unexpected status" do
    expect(Mock, :get, fn _ -> {:ok, %{status: 404, body: "not here"}} end)

    assert {:error, {:unexpected_status, 404}} = Fetcher.fetch_greeting(@url)
  end

  test "reports a body that is not JSON" do
    expect(Mock, :get, fn _ -> {:ok, %{status: 200, body: "<html>"}} end)

    assert {:error, :invalid_json} = Fetcher.fetch_greeting(@url)
  end

  test "reports JSON that is not a greeting" do
    expect(Mock, :get, fn _ -> {:ok, %{status: 200, body: ~s({"other":1})}} end)

    assert {:error, :not_a_greeting} = Fetcher.fetch_greeting(@url)
  end

  test "passes transport errors through" do
    expect(Mock, :get, fn _ -> {:error, :econnrefused} end)

    assert {:error, :econnrefused} = Fetcher.fetch_greeting(@url)
  end
end
