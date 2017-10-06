defmodule ExpcTest do
  use ExUnit.Case
  doctest Expc

  test "greets the world" do
    assert Expc.hello() == :world
  end
end
