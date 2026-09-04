defmodule HelloWorld.DemoTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  test "run/0 prints and returns the greeting" do
    {result, output} = with_io(fn -> HelloWorld.Demo.run() end)

    assert output =~ ~s(Result: {"name":"Claude")
    assert Jason.decode!(result)["name"] == "Claude"
  end
end
