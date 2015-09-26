defmodule Experimental.EnumPadTest do
  use ExUnit.Case, async: true

  require Logger
  import Experimental.EnumPad

  doctest Experimental.EnumPad, import: true

  defp build_emumerables(range) do
    [ range,
      Enum.to_list(range),
      Stream.into(range, []),
    ]
  end

  @empty_enumerables [%{}, []]

  defp cyc(list) do
    Stream.cycle(list)
  end

  test "enumerable?" do
    assert enumerable?([])
    assert enumerable?([1])
    assert enumerable?([1, 2, 3])
    assert enumerable?(1..10)
    assert enumerable?(%{})
    assert enumerable?(%{a: 1, b: 2})
    assert enumerable?([a: 1])
    assert enumerable?([a: 1, b: 2])
    assert enumerable?(Stream.cycle([nil]))
    assert enumerable?(Stream.into(1..10, []))
    
    refute enumerable?(nil)
    refute enumerable?(1)
    refute enumerable?({})
    refute enumerable?({1})
    refute enumerable?({1, 2})
    refute enumerable?(&(&1))
    refute enumerable?(fn -> [] end)
  end

  test "pad: size > length of enumerable" do
    for enum <- build_emumerables(1..3) do
      assert pad(enum, 5)            == [1, 2, 3, nil, nil]
      assert pad(enum, 5, cyc([42])) == [1, 2, 3, 42, 42]
      assert pad(enum, 5, &(&1+10))  == [1, 2, 3, 13, 23]
    end
  end

  test "pad: size < length of enumerable" do
    for enum <- build_emumerables(1..5) do
      assert pad(enum, 3)            == Enum.to_list(enum)
      assert pad(enum, 3, cyc([42])) == Enum.to_list(enum)
      assert pad(enum, 3, &(&1+10))  == Enum.to_list(enum)
    end
  end

  test "pad: size == length of enumerable" do
    for enum <- build_emumerables(1..5) do
      assert pad(enum, 5)            == Enum.to_list(enum)
      assert pad(enum, 5, cyc([42])) == Enum.to_list(enum)
      assert pad(enum, 5, &(&1+10))  == Enum.to_list(enum)
    end
  end

  test "pad: size == +1 size of enumerable" do
    for enum <- build_emumerables(1..5) do
      assert pad(enum, 6)           == [1, 2, 3, 4, 5, nil]
      assert pad([], 1, cyc([42]))  == [42]
    end
  end

  test "pad: 1 element enumerable" do
    for enum <- build_emumerables(10000..10000) do
      assert pad(enum, 0)    == Enum.to_list(enum)
      assert pad(enum, -100) == Enum.to_list(enum)
      assert pad(enum, 1)    == Enum.to_list(enum)
      assert pad(enum, 5) 
        == [10000, nil, nil, nil, nil]
      assert pad(enum, 5, fn(x) -> x + 10 end)
        == [10000, 10010, 10020, 10030, 10040]
    end
  end

  test "pad: empty enumerable" do
    for enum <- @empty_enumerables do
      assert pad(enum, 5)            == [nil, nil, nil, nil, nil]
      assert pad(enum, 5, cyc([42])) == [42, 42, 42, 42, 42]
      assert pad(enum, 1, cyc([0]))  == [0]
      assert pad(enum, 5, fn
        nil -> 0
        x -> x + 10
      end) == [0, 10, 20, 30, 40]
    end
  end

  test "pad: size == 0" do
    for enum <- build_emumerables(1..3) do
      assert pad(enum, 0)            == Enum.to_list(enum)
      assert pad(enum, 0, cyc([42])) == Enum.to_list(enum)
      assert pad(enum, 0, &(&1+10))  == Enum.to_list(enum)
    end

    for enum <- @empty_enumerables do
      assert pad(enum, 0)            == []
      assert pad(enum, 0, cyc([42])) == []
      assert pad(enum, 0, &(&1+10))  == []
    end
  end

  test "pad: negative size" do
    for enum <- build_emumerables(1..5) do
      assert pad(enum, -100)           == Enum.to_list(enum)
      assert pad(enum, -100, &(&1+10)) == Enum.to_list(enum)
    end
  end

  test "pad: check optimization" do
    for enum <- build_emumerables(1..1_000_000) do
      assert pad(enum, 1_000_005, &(&1+10)) == 
        :"Elixir.Enum".reverse(
          [1_000_050, 1_000_040, 1_000_030, 1_000_020, 1_000_010
          | :"Elixir.Enum".reverse(enum)])
        |> Enum.to_list
    end
  end

  test "pad: range" do
    for enum <- build_emumerables(1..3) do
      assert pad(enum, 5)            == [1, 2, 3, nil, nil]
      assert pad(enum, 5, cyc([42])) == [1, 2, 3, 42, 42]
      assert pad(enum, 5, &(&1+10))  == [1, 2, 3, 13, 23]
    end
  end

  test "pad: map and keyword list" do
    enums = [
      %{a: 1, b: 2, c: 3},
      [a: 1, b: 2, c: 3]
    ]
    for enum <- enums do
      assert pad(enum, 5)
        == [{:a, 1}, {:b, 2}, {:c, 3}, nil, nil]
      assert pad(enum, 5, cyc([42]))
        == [{:a, 1}, {:b, 2}, {:c, 3}, 42, 42]
      assert pad(enum, 5, fn({_k,v}) -> {nil, v + 10} end)
        == [{:a, 1}, {:b, 2}, {:c, 3}, {nil, 13}, {nil, 23}]
    end
  end

  test "pad: edge cases" do
    assert pad([:a], 2, cyc([0])) == [:a, 0]
  end
end