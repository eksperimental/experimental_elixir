defmodule Experimental.EnumZipPadTest do
  use ExUnit.Case, async: true

  require Logger
  alias Experimental.EnumZipPad, as: Enum

  doctest Experimental.EnumZipPad, import: true

  #@tag :skip
  test "zip_pad: same length" do
    a = [:a, :b, :c]
    b = [1, 2, 3]
    result = [{:a, 1}, {:b, 2}, {:c, 3}]
    assert Enum.zip_pad(a, b)  == result
    assert Enum.zip_pad(a, b, :z, 0)  == result
  end

  test "zip_pad: a longer than b" do
    a = [:a, :b, :c, :d, :e]
    b = [1, 2, 3]
    assert Enum.zip_pad(a, b)  == [{:a, 1}, {:b, 2}, {:c, 3}, {:d, nil}, {:e, nil}]
    assert Enum.zip_pad(a, b, :z, 0)  == [{:a, 1}, {:b, 2}, {:c, 3}, {:d, 0}, {:e, 0}]
  end

  test "zip_pad: a shorter than b" do
    a = [:a, :b, :c]
    b = [1, 2, 3, 4, 5]
    assert Enum.zip_pad(a, b)  == [{:a, 1}, {:b, 2}, {:c, 3}, {nil, 4}, {nil, 5}]
    assert Enum.zip_pad(a, b, :z, 0)  == [{:a, 1}, {:b, 2}, {:c, 3}, {:z, 4}, {:z, 5}]
  end

  test "zip_pad: empty collection" do
    a = [:a, :b, :c]
    b = [1, 2, 3]
    assert Enum.zip_pad(a, [], :z, 0)  == [{:a, 0}, {:b, 0}, {:c, 0}]
    assert Enum.zip_pad([], b, :z, 0)  == [{:z, 1}, {:z, 2}, {:z, 3}]
    assert Enum.zip_pad([], [], :z, 0)  == []
  end

  test "zip_pad: 1 element" do
    assert Enum.zip_pad([:a], [1], :z, 0)  == [{:a, 1}]
    assert Enum.zip_pad([:a], [], :z, 0)  == [{:a, 0}]
    assert Enum.zip_pad([], [1], :z, 0)  == [{:z, 1}]
  end

end