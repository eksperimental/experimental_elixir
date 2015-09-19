defmodule Experimental.EnumPadTest do
  use ExUnit.Case, async: true

  require Logger
  alias Experimental.EnumPad, as: Enum

  doctest Experimental.EnumPad, import: true

  #@tag :skip
  test "pad: size > length of collection" do
    col = [1, 2, 3]
    assert Enum.pad(col, 5)  == [1, 2, 3, nil, nil]
    assert Enum.pad(col, 5, 42)  == [1, 2, 3, 42, 42]
    assert Enum.pad(col, 5, &(&1+10))  == [1, 2, 3, 13, 23]
  end

  #@tag :skip
  test "pad: size < length of collection" do
    col = [1, 2, 3, 4, 5]
    assert Enum.pad(col, 3)  == col
    assert Enum.pad(col, 3, 42)  == col
    assert Enum.pad(col, 3, &(&1+10))  == col
  end

  #@tag :skip
  test "pad: size == length of collection" do
    col = [1, 2, 3, 4, 5]
    assert Enum.pad(col, 5)  == col
    assert Enum.pad(col, 5, 42)  == col
    assert Enum.pad(col, 5, &(&1+10))  == col
  end

  #@tag :skip
  test "pad: 1 element collection" do
    col = [10000]
    assert Enum.pad(col, 0)  == col
    assert Enum.pad(col, -100)  == col
    assert Enum.pad(col, 1)  == col
    assert Enum.pad(col, 5)  == [10000, nil, nil, nil, nil]
    assert Enum.pad(col, 5, fn(x) -> x + 10 end)  == [10000, 10010, 10020, 10030, 10040]
  end

  #@tag :skip
  test "pad: empty collection" do
    assert Enum.pad([], 5)  == []
    assert Enum.pad([], 5, 42)  == []
    assert Enum.pad([], 5, &(&1+10))  == []
  end

  #@tag :skip
  test "pad: negative size" do
    col = [1, 2, 3, 4, 5]
    assert Enum.pad(col, 0)  == col
    assert Enum.pad(col, -100)  == col
    assert Enum.pad(col, -100, &(&1+10))  == col
  end

  #@tag :skip
  test "pad: check optimization" do
    col = 1..1_000_000 |> :"Elixir.Enum".to_list
    assert Enum.pad(col, 1_000_005, &(&1+10))  == 
      :"Elixir.Enum".reverse( [1_000_050, 1_000_040, 1_000_030, 1_000_020, 1_000_010 | :"Elixir.Enum".reverse(col)] )
  end

  # test "pad: range" do
  #   col = 1..3
  #   assert Enum.pad(col, 5)  == [1, 2, 3, nil, nil]
  #   assert Enum.pad(col, 5, 42)  == [1, 2, 3, 42, 42]
  #   assert Enum.pad(col, 5, &(&1+10))  == [1, 2, 3, 13, 23]
  # end

  # test "pad: map" do
  #   col = %{a: 1, b: 2, c: 3}
  #   assert Enum.pad(col, 5)  == [{:a, 1}, {:b, 2}, {:c, 3}, nil, nil]
  #   assert Enum.pad(col, 5, 42)  == [{:a, 1}, {:b, 2}, {:c, 3}, 42, 42]
  #   #assert Enum.pad(col, 5, &(&1+10))  == [{:a, 1}, {:b, 2}, {:c, 3}, 13, 23]
  # end

end