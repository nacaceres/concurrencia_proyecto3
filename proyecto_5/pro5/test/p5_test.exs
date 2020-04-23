defmodule P5Test do
  use ExUnit.Case
  doctest P5

  test "greets the world" do
    assert P5.hello() == :world
  end
end
