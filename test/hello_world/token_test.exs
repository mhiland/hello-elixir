defmodule HelloWorld.TokenTest do
  use ExUnit.Case, async: true

  @secret "test-only-secret-not-for-production"

  test "sign_greeting/2 produces a JWS that verifies back to the greeting" do
    token = HelloWorld.Token.sign_greeting("Tester", @secret)

    assert [_header, _payload, _signature] = String.split(token, ".")

    assert {:ok, %{"name" => "Tester", "status" => "success"}} =
             HelloWorld.Token.verify(token, @secret)
  end

  test "verify/2 rejects a token signed with a different secret" do
    token = HelloWorld.Token.sign_greeting("Tester", @secret)

    assert :error == HelloWorld.Token.verify(token, "another-secret")
  end
end
