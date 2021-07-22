defmodule TextStateServerTest do
  use ExUnit.Case
  doctest TextStateServer

  test "greets the world" do
    assert TextStateServer.hello() == :world
  end
end
