defmodule HelloWorld.Demo do
  @moduledoc "Runs the greeting demo, logging as it goes."

  require Logger

  @doc "Greets a fixed name, prints the result, and returns it."
  @spec run() :: String.t()
  def run do
    name = "Claude"
    Logger.info("Starting Hello World Demo...")

    result = HelloWorld.greet(name)

    IO.puts("Result: #{result}")

    Logger.info("Demo finished successfully.")
    result
  end
end
