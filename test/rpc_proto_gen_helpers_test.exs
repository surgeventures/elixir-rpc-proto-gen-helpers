defmodule RPCProtoGenHelpersTest do
  use ExUnit.Case
  doctest RPCProtoGenHelpers

  test "greets the world" do
    assert RPCProtoGenHelpers.hello() == :world
  end
end
