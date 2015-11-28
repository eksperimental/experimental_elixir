defmodule Experimental.KernelGuardTest do
  use ExUnit.Case, async: true
  import Kernel, except: [guard: 1, guard: 2, guardp: 1, guardp: 2, ]
  import Experimental.KernelGuard

  require Logger
  require Integer

  @spec both_even_or_odd(number, number) :: :ok
  guard both_even_or_odd(a, b) when is_integer(a) and is_integer(b) do
    Integer.is_even(a) and Integer.is_even(b) or Integer.is_odd(a) and Integer.is_odd(b)
  end

  guard both_even_or_odd(a, b) when is_float(a) and is_float(b) do
    (a / 2) - trunc(a / 2) == 0.0 and (b / 2) - trunc(b / 2) == 0.0
    or
    (a / 2) - trunc(a / 2) != 0.0 and (b / 2) - trunc(b / 2) != 0.0
  end

  def both_even_or_odd(a, b) when is_number(a) and is_number(b) do
    :ok
  end

  test "both_even_or_odd/2" do
    assert both_even_or_odd(3, -1) == :ok
    assert both_even_or_odd(3, 1) == :ok
    assert_raise FunctionClauseGuardError,
      "test/kernel_guard.exs:10: no function clause matching the guard in Experimental.KernelGuardTest.guard/2",
      fn ->
        both_even_or_odd(3, 0)
      end

    assert_raise FunctionClauseGuardError,
      "test/kernel_guard.exs:14: no function clause matching the guard in Experimental.KernelGuardTest.guard/2",
      fn ->
        both_even_or_odd(3.0, 0.0)
      end

    assert_raise FunctionClauseError,
      "no function clause matching in Experimental.KernelGuardTest.both_even_or_odd/2",
      fn ->
        both_even_or_odd("3", "1")
      end
  end

  # Default value
  @spec check_default(pos_integer, neg_integer) :: :ok
  guard check_default(a, b \\ -1) when 1 == 1 when 2 == 2 do
    is_integer(a) and a > 0 and is_integer(b) and b < 0
  end
  def check_default(a, b) when is_integer(a) and is_integer(b) do
    b
  end

  test "check_default/2" do
    assert check_default(3) == -1
    assert check_default(3, -1) == -1
    assert check_default(3, -2) == -2
  end


  # Pattern matching
  @spec pattern_matching(list) :: tuple
  guard pattern_matching(list = [h|t]) do
    is_integer(h) and is_list(t) and length(list) == 3
  end
  def pattern_matching(list = [h|t]) do
    {h, t, list}
  end

  test "pattern_matching/2" do
    assert pattern_matching([1, 2, 3]) == {1, [2, 3], [1, 2, 3]}

    assert_raise FunctionClauseGuardError,
      "test/kernel_guard.exs:64: no function clause matching the guard in Experimental.KernelGuardTest.guard/2",
      fn ->
        pattern_matching([1, 2, 3, 4])
      end

    assert_raise FunctionClauseError,
      fn ->
        pattern_matching({1, 2, 3, 4})
      end
  end
end
