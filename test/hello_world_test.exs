defmodule HelloWorldTest do
  use ExUnit.Case, async: true
  doctest HelloWorld

  test "greet/1 encodes the name into the JSON message" do
    result = HelloWorld.greet("Tester")
    data = Jason.decode!(result)

    assert data["name"] == "Tester"
    assert data["status"] == "success"
  end

  test "encode_message/1 round-trips through Jason" do
    assert %{"answer" => 42} == HelloWorld.encode_message(%{answer: 42}) |> Jason.decode!()
  end
end
