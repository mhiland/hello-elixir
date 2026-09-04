defmodule HelloWorld.Token do
  @moduledoc """
  Signs a greeting as a compact JSON Web Signature (JWS) using `jose`.

  The secret is always supplied by the caller; nothing here embeds one.
  """

  @doc """
  Returns the greeting for `name` signed with HMAC-SHA256 under `secret`.
  """
  @spec sign_greeting(String.t(), binary()) :: String.t()
  def sign_greeting(name, secret) when is_binary(name) and is_binary(secret) do
    jwk = JOSE.JWK.from_oct(secret)
    payload = HelloWorld.greet(name)
    {_alg, compact} = jwk |> JOSE.JWS.sign(payload, %{"alg" => "HS256"}) |> JOSE.JWS.compact()
    compact
  end

  @doc """
  Verifies `token` under `secret` and returns the decoded greeting.
  """
  @spec verify(String.t(), binary()) :: {:ok, map()} | :error
  def verify(token, secret) when is_binary(token) and is_binary(secret) do
    jwk = JOSE.JWK.from_oct(secret)

    case JOSE.JWS.verify_strict(jwk, ["HS256"], token) do
      {true, payload, _jws} -> {:ok, Jason.decode!(payload)}
      _ -> :error
    end
  end
end
