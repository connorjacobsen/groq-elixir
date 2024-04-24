defmodule GroqTest do
  use ExUnit.Case
  doctest Groq

  test "greets the world" do
    assert Groq.hello() == :world
  end
end
